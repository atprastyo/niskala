// Apply restrained generated surface detail without changing source alpha or poses.
// clang -framework Foundation -framework AppKit -framework ImageIO tools/export_arka_details.m -o /tmp/export-arka-details
// /tmp/export-arka-details [output-root]
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <ImageIO/ImageIO.h>
static CGContextRef canvas(int w,int h){CGColorSpaceRef s=CGColorSpaceCreateDeviceRGB();CGContextRef c=CGBitmapContextCreate(NULL,w,h,8,w*4,s,kCGImageAlphaPremultipliedLast);CGColorSpaceRelease(s);return c;}
static CGImageRef load(NSString*p){CGImageSourceRef s=CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:p],NULL);NSCAssert(s,@"Missing %@",p);CGImageRef i=CGImageSourceCreateImageAtIndex(s,0,NULL);CFRelease(s);return i;}
static void save(CGImageRef i,NSString*p){CGImageDestinationRef d=CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:p],CFSTR("public.png"),1,NULL);CGImageDestinationAddImage(d,i,NULL);NSCAssert(CGImageDestinationFinalize(d),@"Export failed");CFRelease(d);}
static double light(const unsigned char*p){return (.2126*p[0]+.7152*p[1]+.0722*p[2])/255.;}
int main(int argc,char**argv){@autoreleasepool{
NSString*root=argc>1?[NSString stringWithUTF8String:argv[1]]:@"assets/images/player/arka";
NSMutableArray*runs=[NSMutableArray array];
for(NSString*action in @[@"idle",@"run",@"attack_1",@"attack_2"]){
 CGImageRef generated=load([NSString stringWithFormat:@"docs/art/arka-detail/%@-detail.png",action]);
 CGContextRef texture=canvas(1536,768);CGContextSetInterpolationQuality(texture,kCGInterpolationHigh);CGContextDrawImage(texture,CGRectMake(0,0,1536,768),generated);
 unsigned char*detail=CGBitmapContextGetData(texture);int row=0;
 for(NSString*direction in @[@"right",@"left",@"up",@"down"]){
  NSString*name=[action stringByReplacingOccurrencesOfString:@"_" withString:@""];
  NSString*relative=[NSString stringWithFormat:@"%@/%@_%@.png",action,name,direction];
  CGImageRef base=load([@"docs/art/arka-detail/base" stringByAppendingPathComponent:relative]);
  NSCAssert(CGImageGetWidth(base)==3072&&CGImageGetHeight(base)==320,@"Unexpected layout");
  CGContextRef out=canvas(3072,320);CGContextDrawImage(out,CGRectMake(0,0,3072,320),base);
  unsigned char*p=CGBitmapContextGetData(out);unsigned char*before=malloc(3072*320*4);memcpy(before,p,3072*320*4);int count=0;
  for(int f=0;f<8;f++)for(int y=3;y<189;y++)for(int x=3;x<189;x++){
   int i=((y+64)*3072+f*384+x+96)*4;unsigned char*b=before+i;
   if(b[3]<250)continue;
   if(b[2]>b[0]*1.3&&b[2]>b[1]*1.1)continue; // Preserve blue eye pixels.
   // Leave skin, facial features, silver and bright slash effects untouched.
   if((b[0]>130&&b[1]>70&&b[1]>b[0]*.5&&b[2]<b[1]*.85)||light(b)>.64)continue;
   int hi=MAX(b[0],MAX(b[1],b[2])),lo=MIN(b[0],MIN(b[1],b[2]));
   if(hi-lo<18&&hi>110)continue;
   BOOL interior=YES;
   for(int dy=-2;dy<=2;dy++)for(int dx=-2;dx<=2;dx++)if(before[i+(dy*3072+dx)*4+3]<250)interior=NO;
   if(!interior)continue;
   int ti=((row*192+y)*1536+f*192+x)*4;unsigned char*t=detail+ti;
   if(t[3]<250)continue;
   double mean=0;int samples=0;
   for(int dy=-3;dy<=3;dy++)for(int dx=-3;dx<=3;dx++){
    unsigned char*q=detail+ti+(dy*1536+dx)*4;if(q[3]>250){mean+=light(q);samples++;}
   }
   if(samples<30)continue;
   mean/=samples;
   double delta=(light(t)-mean)*2+(light(t)-light(b))*.18;
   double gain=1+MAX(-.30,MIN(.30,delta));
   for(int c=0;c<3;c++)p[i+c]=MIN(b[3],MAX(0,lround(b[c]*gain)));
   count++;
  }
  // The entire smoothed outline, all foot positions and effect coverage stay identical.
  for(int i=3;i<3072*320*4;i+=4)NSCAssert(p[i]==before[i],@"Alpha changed");
  CGImageRef result=CGBitmapContextCreateImage(out);
  NSString*target=[root stringByAppendingPathComponent:relative];
  [[NSFileManager defaultManager]createDirectoryAtPath:[target stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
  save(result,target);printf("%s: %d interior detail samples; alpha unchanged\n",[relative UTF8String],count);
  if([action isEqualToString:@"run"])[runs addObject:(__bridge id)result];
  free(before);CGContextRelease(out);CGImageRelease(base);row++;
 }
 CGContextRelease(texture);CGImageRelease(generated);
}
CGContextRef preview=canvas(768,192);
CGImageDestinationRef gif=CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:@"docs/art/arka-hd/run-preview.gif"],CFSTR("com.compuserve.gif"),8,NULL);
CGImageDestinationSetProperties(gif,(__bridge CFDictionaryRef)@{(__bridge NSString*)kCGImagePropertyGIFDictionary:@{(__bridge NSString*)kCGImagePropertyGIFLoopCount:@0}});
for(int f=0;f<8;f++){
 CGContextSetRGBFillColor(preview,.15,.16,.18,1);CGContextFillRect(preview,CGRectMake(0,0,768,192));
 for(int row=0;row<4;row++){CGImageRef crop=CGImageCreateWithImageInRect((__bridge CGImageRef)runs[row],CGRectMake(f*384+96,64,192,192));CGContextDrawImage(preview,CGRectMake(row*192,0,192,192),crop);CGImageRelease(crop);}
 CGImageRef im=CGBitmapContextCreateImage(preview);
 CGImageDestinationAddImage(gif,im,(__bridge CFDictionaryRef)@{(__bridge NSString*)kCGImagePropertyGIFDictionary:@{(__bridge NSString*)kCGImagePropertyGIFDelayTime:@.07}});
 if(f==2)save(im,@"docs/art/arka-detail/preview.png");CGImageRelease(im);
}
NSCAssert(CGImageDestinationFinalize(gif),@"GIF export failed");return 0;
}}
