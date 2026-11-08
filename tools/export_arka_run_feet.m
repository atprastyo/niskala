// clang -framework Foundation -framework AppKit -framework ImageIO tools/export_arka_run_feet.m -o /tmp/export-arka-run-feet
// /tmp/export-arka-run-feet [output-root]
// Restore pose registration from the reference; use generated HD lower-body artwork.
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <ImageIO/ImageIO.h>
static CGImageRef load(NSString *p) {
    CGImageSourceRef s=CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:p],NULL);
    NSCAssert(s, @"Missing image %@",p);
    CGImageRef image=CGImageSourceCreateImageAtIndex(s,0,NULL); CFRelease(s); return image;
}
static CGContextRef context(int w,int h) {
    CGColorSpaceRef space=CGColorSpaceCreateDeviceRGB();
    CGContextRef c=CGBitmapContextCreate(NULL,w,h,8,w*4,space,kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(space); CGContextSetInterpolationQuality(c,kCGInterpolationHigh); return c;
}
static void save(CGImageRef image,NSString *path) {
    CGImageDestinationRef d=CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path],CFSTR("public.png"),1,NULL);
    CGImageDestinationAddImage(d,image,NULL); NSCAssert(CGImageDestinationFinalize(d),@"PNG export failed");CFRelease(d);
}
// Bounds in top-origin coordinates, ignoring the sword's neutral highlights.
static CGRect legs(CGImageRef image) {
    CGContextRef c=context(192,192); CGContextDrawImage(c,CGRectMake(0,0,192,192),image);
    unsigned char *p=CGBitmapContextGetData(c); int x0=192,y0=192,x1=0,y1=0;
    for(int y=120;y<192;y++)for(int x=16;x<176;x++) {
        int i=(y*192+x)*4;
        if(p[i+3]>128 && !(p[i]>150&&p[i+1]>150&&p[i+2]>140)) {
            x0=MIN(x0,x);x1=MAX(x1,x);y0=MIN(y0,y);y1=MAX(y1,y);
        }
    }
    CGContextRelease(c); NSCAssert(x1>x0&&y1>y0,@"Missing legs");
    return CGRectMake(x0,y0,x1-x0+1,y1-y0+1);
}
int main(int argc,char **argv) {@autoreleasepool {
    NSString *root=argc>1?[NSString stringWithUTF8String:argv[1]]:@"assets/images/player/arka";
    CGImageRef reference=load(@"docs/art/arka-hd/run-pose-reference.png");
    CGImageRef generated=load(@"docs/art/arka-hd/run-hd-feet-atlas.png");
    CGContextRef normalized=context(1536,768);CGContextDrawImage(normalized,CGRectMake(0,0,1536,768),generated);
    CGImageRef atlas=CGBitmapContextCreateImage(normalized);
    CGContextRef preview=context(768,192);
    NSArray *directions=@[@"right",@"left",@"up",@"down"];
    NSString *gifPath=@"docs/art/arka-hd/run-preview.gif";
    CGImageDestinationRef gif=CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:gifPath],CFSTR("com.compuserve.gif"),8,NULL);
    CGImageDestinationSetProperties(gif,(__bridge CFDictionaryRef)@{(__bridge NSString*)kCGImagePropertyGIFDictionary:@{(__bridge NSString*)kCGImagePropertyGIFLoopCount:@0}});
    NSMutableArray *outputs=[NSMutableArray array];
    for(int row=0;row<4;row++) {
        CGContextRef strip=context(3072,320);
        for(int frame=0;frame<8;frame++) {
            CGRect cell=CGRectMake(frame*192,row*192,192,192);
            CGImageRef ref=CGImageCreateWithImageInRect(reference,cell);
            CGImageRef art=CGImageCreateWithImageInRect(atlas,cell);
            CGRect target=legs(ref), source=legs(art);
            CGImageRef lower=CGImageCreateWithImageInRect(art,source);
            CGContextSaveGState(strip);
            CGContextClipToRect(strip,CGRectMake(frame*384,136,384,184));
            CGContextDrawImage(strip,CGRectMake(frame*384+96,64,192,192),ref);
            CGContextRestoreGState(strip);
            CGContextSaveGState(strip);
            CGContextClipToRect(strip,CGRectMake(frame*384+96,64,192,72));
            CGContextDrawImage(strip,CGRectMake(frame*384+96+target.origin.x,320-64-CGRectGetMaxY(target),target.size.width,target.size.height),lower);
            CGContextRestoreGState(strip);
            printf("%s frame %d: lower-body target %.0f %.0f %.0f %.0f\n",[directions[row] UTF8String],frame,target.origin.x,target.origin.y,target.size.width,target.size.height);
            CGImageRelease(lower);CGImageRelease(ref);CGImageRelease(art);
        }
        CGImageRef output=CGBitmapContextCreateImage(strip);
        NSString *path=[NSString stringWithFormat:@"%@/run/run_%@.png",root,directions[row]];
        save(output,path);[outputs addObject:(__bridge id)output];CGContextRelease(strip);
    }
    for(int frame=0;frame<8;frame++) {
        CGContextSetRGBFillColor(preview,.15,.16,.18,1);CGContextFillRect(preview,CGRectMake(0,0,768,192));
        for(int row=0;row<4;row++) {
            CGImageRef crop=CGImageCreateWithImageInRect((__bridge CGImageRef)outputs[row],CGRectMake(frame*384+96,64,192,192));
            CGContextDrawImage(preview,CGRectMake(row*192,0,192,192),crop);CGImageRelease(crop);
        }
        CGImageRef im=CGBitmapContextCreateImage(preview);
        CGImageDestinationAddImage(gif,im,(__bridge CFDictionaryRef)@{(__bridge NSString*)kCGImagePropertyGIFDictionary:@{(__bridge NSString*)kCGImagePropertyGIFDelayTime:@0.10}});
        if(frame==2)save(im,@"docs/art/arka-hd/run-feet-preview.png");
        CGImageRelease(im);
    }
    NSCAssert(CGImageDestinationFinalize(gif),@"GIF export failed");
    return 0;
}}
