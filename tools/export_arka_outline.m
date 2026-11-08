// Final pass: dark character contour; retain the saved pre-straightening sword artwork.
// clang -framework Foundation -framework AppKit -framework ImageIO tools/export_arka_outline.m -o /tmp/export-arka-outline
// /tmp/export-arka-outline [output-root]
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <ImageIO/ImageIO.h>
static CGContextRef canvas(int w,int h){CGColorSpaceRef s=CGColorSpaceCreateDeviceRGB();CGContextRef c=CGBitmapContextCreate(NULL,w,h,8,w*4,s,kCGImageAlphaPremultipliedLast);CGColorSpaceRelease(s);return c;}
static CGImageRef load(NSString*p){CGImageSourceRef s=CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:p],NULL);NSCAssert(s,@"Missing %@",p);CGImageRef i=CGImageSourceCreateImageAtIndex(s,0,NULL);CFRelease(s);return i;}
static void save(CGImageRef i,NSString*p){CGImageDestinationRef d=CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:p],CFSTR("public.png"),1,NULL);CGImageDestinationAddImage(d,i,NULL);NSCAssert(CGImageDestinationFinalize(d),@"PNG export failed");CFRelease(d);}
int main(int argc,char**argv){@autoreleasepool{
NSString*root=argc>1?[NSString stringWithUTF8String:argv[1]]:@"assets/images/player/arka";
NSMutableArray*runs=[NSMutableArray array];
for(NSString*action in @[@"idle",@"run",@"attack_1",@"attack_2"]){
 NSString*name=[action stringByReplacingOccurrencesOfString:@"_" withString:@""];
 for(NSString*direction in @[@"right",@"left",@"up",@"down"]){
  NSString*relative=[NSString stringWithFormat:@"%@/%@_%@.png",action,name,direction];CGImageRef base=load([@"docs/art/arka-outline/base" stringByAppendingPathComponent:relative]);
  CGContextRef strip=canvas(3072,320);
  for(int f=0;f<8;f++){
   CGImageRef cell=CGImageCreateWithImageInRect(base,CGRectMake(f*384,0,384,320));CGContextRef frame=canvas(384,320);CGContextDrawImage(frame,CGRectMake(0,0,384,320),cell);
   unsigned char*p=CGBitmapContextGetData(frame);
   // Crisp warm-charcoal contour, two source pixels wide, blended under the original art.
   unsigned char*copy=malloc(384*320*4);memcpy(copy,p,384*320*4);
   for(int y=66;y<254;y++)for(int x=98;x<286;x++){
    int i=(y*384+x)*4;double ring=0;
    for(int dy=-3;dy<=3;dy++)for(int dx=-3;dx<=3;dx++){
     double distance=hypot(dx,dy);if(distance>2.5)continue;unsigned char*n=copy+((y+dy)*384+x+dx)*4;
     // Broad bright arcs retain their light edges; blade artwork has its own dark edge.
     if(n[0]>140&&n[1]>140&&n[2]>140)continue;
     double a=n[3]/255.;ring=MAX(ring,a*MAX(0,MIN(1,2.5-distance)));
    }
    double under=ring*(1-copy[i+3]/255.);
    p[i]=MIN(255,lround(copy[i]+41*under));p[i+1]=MIN(255,lround(copy[i+1]+31*under));p[i+2]=MIN(255,lround(copy[i+2]+30*under));p[i+3]=MIN(255,lround(copy[i+3]+255*under));
   }
   free(copy);CGImageRef result=CGBitmapContextCreateImage(frame);CGContextDrawImage(strip,CGRectMake(f*384,0,384,320),result);CGImageRelease(result);CGContextRelease(frame);CGImageRelease(cell);
  }
  CGImageRef result=CGBitmapContextCreateImage(strip);NSString*target=[root stringByAppendingPathComponent:relative];[[NSFileManager defaultManager]createDirectoryAtPath:[target stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];save(result,target);
  printf("%s: bold character contour, original sword restored\n",[relative UTF8String]);if([action isEqualToString:@"run"])[runs addObject:(__bridge id)result];CGContextRelease(strip);CGImageRelease(base);
 }
}
CGContextRef preview=canvas(768,192);CGImageDestinationRef gif=CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:@"docs/art/arka-hd/run-preview.gif"],CFSTR("com.compuserve.gif"),8,NULL);CGImageDestinationSetProperties(gif,(__bridge CFDictionaryRef)@{(__bridge NSString*)kCGImagePropertyGIFDictionary:@{(__bridge NSString*)kCGImagePropertyGIFLoopCount:@0}});
for(int f=0;f<8;f++){CGContextSetRGBFillColor(preview,.15,.16,.18,1);CGContextFillRect(preview,CGRectMake(0,0,768,192));for(int row=0;row<4;row++){CGImageRef crop=CGImageCreateWithImageInRect((__bridge CGImageRef)runs[row],CGRectMake(f*384+96,64,192,192));CGContextDrawImage(preview,CGRectMake(row*192,0,192,192),crop);CGImageRelease(crop);}CGImageRef im=CGBitmapContextCreateImage(preview);CGImageDestinationAddImage(gif,im,(__bridge CFDictionaryRef)@{(__bridge NSString*)kCGImagePropertyGIFDictionary:@{(__bridge NSString*)kCGImagePropertyGIFDelayTime:@.07}});if(f==2)save(im,@"docs/art/arka-outline/preview.png");CGImageRelease(im);}NSCAssert(CGImageDestinationFinalize(gif),@"GIF export failed");return 0;
}}
