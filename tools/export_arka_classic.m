// Preserve original Arka motion; recolor, enlarge 4x with Scale2x contours, and antialias edges.
// clang -framework Foundation -framework AppKit -framework ImageIO tools/export_arka_classic.m -o /tmp/export-arka-classic
// /tmp/export-arka-classic [output-root]
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <ImageIO/ImageIO.h>
static CGContextRef canvas(int w,int h) {
    CGColorSpaceRef space=CGColorSpaceCreateDeviceRGB();
    CGContextRef c=CGBitmapContextCreate(NULL,w,h,8,w*4,space,kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(space);return c;
}
static void save(CGImageRef image,NSString *path) {
    CGImageDestinationRef d=CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path],CFSTR("public.png"),1,NULL);
    CGImageDestinationAddImage(d,image,NULL);NSCAssert(CGImageDestinationFinalize(d),@"PNG export failed");CFRelease(d);
}
// Scale2x preserves flat pixel-art details while rounding supported diagonal corners.
static void scale2x(const uint32_t *src,uint32_t *dst,int w,int h) {
    for(int y=0;y<h;y++)for(int x=0;x<w;x++) {
        uint32_t e=src[y*w+x],b=src[MAX(0,y-1)*w+x],d=src[y*w+MAX(0,x-1)];
        uint32_t f=src[y*w+MIN(w-1,x+1)],hh=src[MIN(h-1,y+1)*w+x];
        int i=(y*2)*(w*2)+x*2;
        dst[i]=(b!=hh&&d!=f&&d==b)?d:e;
        dst[i+1]=(b!=hh&&d!=f&&b==f)?f:e;
        dst[i+w*2]=(b!=hh&&d!=f&&d==hh)?d:e;
        dst[i+w*2+1]=(b!=hh&&d!=f&&hh==f)?f:e;
    }
}
// Small premultiplied-RGBA filter only along transparency boundaries.
// Interior color clusters stay sharp; alpha blending avoids dark matte outlines.
static void antialias(unsigned char *pixels,int w,int h) {
    unsigned char *copy=malloc(w*h*4);memcpy(copy,pixels,w*h*4);
    const int kernel[3]={1,4,1};
    for(int y=1;y<h-1;y++)for(int x=1;x<w-1;x++) {
        int i=(y*w+x)*4;BOOL edge=NO;
        for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++)
            if(copy[((y+dy)*w+x+dx)*4+3]!=copy[i+3])edge=YES;
        if(!edge)continue;
        for(int channel=0;channel<4;channel++) {
            int sum=0;
            for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++)
                sum+=copy[((y+dy)*w+x+dx)*4+channel]*kernel[dy+1]*kernel[dx+1];
            pixels[i+channel]=(sum+18)/36;
        }
    }
    free(copy);
}
int main(int argc,char**argv){@autoreleasepool{
    NSString *root=argc>1?[NSString stringWithUTF8String:argv[1]]:@"assets/images/player/arka";
    // Exact palette substitutions preserve skin, silver sword and slash highlights.
    NSDictionary *palette=@{@0x391f21:@0x493426,@0x571c27:@0x64352c,
        @0x5d2c28:@0x704831,@0x891e2b:@0xa54236,@0xc42430:@0xc9674d,
        @0x1b1b1b:@0x211e23,@0x272727:@0x302c32,@0x3d3d3d:@0x49434b,
        @0x2a2f4e:@0x74634d,@0x424c6e:@0xa18c6c,@0x92a1b9:@0xe8d5af};
    NSMutableArray *runs=[NSMutableArray array];
    for(NSString *action in @[@"idle",@"run",@"attack_1",@"attack_2"]){
        NSString *name=[action stringByReplacingOccurrencesOfString:@"_" withString:@""];
        for(NSString *direction in @[@"right",@"left",@"up",@"down"]){
            NSString *relative=[NSString stringWithFormat:@"%@/%@_%@.png",action,name,direction];
            NSString *path=[@"docs/art/arka-originals" stringByAppendingPathComponent:relative];
            CGImageSourceRef src=CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path],NULL);
            NSCAssert(src,@"Missing original %@",path);
            CGImageRef image=CGImageSourceCreateImageAtIndex(src,0,NULL);
            NSCAssert(CGImageGetWidth(image)==768&&CGImageGetHeight(image)==80,@"Unexpected layout");
            CGContextRef source=canvas(768,80);CGContextDrawImage(source,CGRectMake(0,0,768,80),image);
            unsigned char *input=CGBitmapContextGetData(source);
            CGContextRef output=canvas(3072,320);unsigned char *pixels=CGBitmapContextGetData(output);
            for(int y=0;y<80;y++)for(int x=0;x<768;x++){
                int i=(y*768+x)*4;unsigned int rgb=(input[i]<<16)|(input[i+1]<<8)|input[i+2];
                NSNumber *mapped=palette[@(rgb)];unsigned int color=mapped?[mapped unsignedIntValue]:rgb;
                input[i]=(color>>16)&255;input[i+1]=(color>>8)&255;input[i+2]=color&255;
                if(input[i+3]==0)input[i]=input[i+1]=input[i+2]=0;
            }
            uint32_t *intermediate=calloc(1536*160,sizeof(uint32_t));
            scale2x((const uint32_t*)input,intermediate,768,80);
            scale2x(intermediate,(uint32_t*)pixels,1536,160);
            free(intermediate);
            antialias(pixels,3072,320);
            CGImageRef result=CGBitmapContextCreateImage(output);
            NSString *target=[root stringByAppendingPathComponent:relative];
            [[NSFileManager defaultManager] createDirectoryAtPath:[target stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
            save(result,target);printf("%s: original poses, recolored, contour-smoothed 4x\n",[relative UTF8String]);
            if([action isEqualToString:@"run"])[runs addObject:(__bridge id)result];
            CGContextRelease(source);CGContextRelease(output);CGImageRelease(image);CFRelease(src);
        }
    }
    CGContextRef preview=canvas(768,192);
    NSString *gifPath=@"docs/art/arka-hd/run-preview.gif";
    CGImageDestinationRef gif=CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:gifPath],CFSTR("com.compuserve.gif"),8,NULL);
    CGImageDestinationSetProperties(gif,(__bridge CFDictionaryRef)@{(__bridge NSString*)kCGImagePropertyGIFDictionary:@{(__bridge NSString*)kCGImagePropertyGIFLoopCount:@0}});
    for(int frame=0;frame<8;frame++){
        CGContextSetRGBFillColor(preview,.15,.16,.18,1);CGContextFillRect(preview,CGRectMake(0,0,768,192));
        for(int row=0;row<4;row++){
            CGImageRef crop=CGImageCreateWithImageInRect((__bridge CGImageRef)runs[row],CGRectMake(frame*384+96,64,192,192));
            CGContextDrawImage(preview,CGRectMake(row*192,0,192,192),crop);CGImageRelease(crop);
        }
        CGImageRef p=CGBitmapContextCreateImage(preview);
        CGImageDestinationAddImage(gif,p,(__bridge CFDictionaryRef)@{(__bridge NSString*)kCGImagePropertyGIFDictionary:@{(__bridge NSString*)kCGImagePropertyGIFDelayTime:@0.07}});
        if(frame==2)save(p,@"docs/art/arka-hd/classic-preview.png");CGImageRelease(p);
    }
    NSCAssert(CGImageDestinationFinalize(gif),@"GIF export failed");return 0;
}}
