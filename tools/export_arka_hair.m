// Recolor only the original connected hair material, preserving alpha and all poses.
// clang -framework Foundation -framework AppKit -framework ImageIO tools/export_arka_hair.m -o /tmp/export-arka-hair
// /tmp/export-arka-hair [output-root]
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
 for(NSString*direction in @[@"right",@"left",@"up",@"down"]){
  NSString*name=[action stringByReplacingOccurrencesOfString:@"_" withString:@""];
  NSString*relative=[NSString stringWithFormat:@"%@/%@_%@.png",action,name,direction];
  CGImageRef base=load([@"docs/art/arka-hair/base" stringByAppendingPathComponent:relative]);
  CGImageRef original=load([@"docs/art/arka-originals" stringByAppendingPathComponent:relative]);
  CGContextRef template=canvas(768,80);CGContextDrawImage(template,CGRectMake(0,0,768,80),original);unsigned char*ref=CGBitmapContextGetData(template);
  CGContextRef out=canvas(3072,320);CGContextDrawImage(out,CGRectMake(0,0,3072,320),base);unsigned char*p=CGBitmapContextGetData(out);int changed=0;
  for(int f=0;f<8;f++) {
   BOOL eligible[96*80]={0},mask[96*80]={0};int seed=-1;
   for(int y=16;y<42;y++)for(int x=24;x<72;x++) {
    unsigned char*c=ref+(y*768+f*96+x)*4;unsigned int rgb=(c[0]<<16)|(c[1]<<8)|c[2];
    BOOL brown=c[3]>128&&(rgb==0x391f21||rgb==0x5d2c28||rgb==0x1c121c);
    eligible[y*96+x]=brown;if(brown&&seed<0)seed=y*96+x;
   }
   NSCAssert(seed>=0,@"Missing hair reference");
   // Use only the connected top-of-head material; do not recolor brown leather.
   int queue[96*80],head=0,tail=1;queue[0]=seed;mask[seed]=YES;int limit=seed/96+14;
   while(head<tail) {
    int v=queue[head++],x=v%96,y=v/96;
    for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++){
     int nx=x+dx,ny=y+dy;if(nx<0||nx>=96||ny<0||ny>=80||ny>limit)continue;int n=ny*96+nx;
     if(eligible[n]&&!mask[n]){mask[n]=YES;queue[tail++]=n;}
    }
   }
   for(int y=64;y<180;y++)for(int x=96;x<288;x++) {
    int i=(y*3072+f*384+x)*4;unsigned char*c=p+i;if(c[3]<32)continue;
    double a=c[3]/255.,r=c[0]/a,g=c[1]/a,b=c[2]/a;
    if(!(r>g*1.13&&r>b*1.12&&r>=48&&r<155&&g<95))continue;
    BOOL hair=NO;
    // One output-pixel tolerance includes contour smoothing of the original mask.
    for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++){
     int nx=(x+dx)/4,ny=(y+dy)/4;if(nx>=0&&nx<96&&ny>=0&&ny<80&&mask[ny*96+nx])hair=YES;
    }
    if(!hair)continue;
    double t=pow(MAX(0,MIN(1,(r-45)/95.)),1.45);
    c[0]=lround((18+(91-18)*t)*a);c[1]=lround((17+(57-17)*t)*a);c[2]=lround((19+(37-19)*t)*a);changed++;
   }
  }
  CGImageRef result=CGBitmapContextCreateImage(out);NSString*target=[root stringByAppendingPathComponent:relative];[[NSFileManager defaultManager]createDirectoryAtPath:[target stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];save(result,target);
  printf("%s: %d black/brown hair pixels, original alpha and coordinates\n",[relative UTF8String],changed);
  if([action isEqualToString:@"run"])[runs addObject:(__bridge id)result];
  CGContextRelease(out);CGContextRelease(template);CGImageRelease(original);CGImageRelease(base);
 }
}
CGContextRef preview=canvas(768,192);
CGImageDestinationRef gif=CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:@"docs/art/arka-hd/run-preview.gif"],CFSTR("com.compuserve.gif"),8,NULL);
CGImageDestinationSetProperties(gif,(__bridge CFDictionaryRef)@{(__bridge NSString*)kCGImagePropertyGIFDictionary:@{(__bridge NSString*)kCGImagePropertyGIFLoopCount:@0}});
for(int f=0;f<8;f++){
 CGContextSetRGBFillColor(preview,.15,.16,.18,1);CGContextFillRect(preview,CGRectMake(0,0,768,192));
 for(int row=0;row<4;row++){CGImageRef crop=CGImageCreateWithImageInRect((__bridge CGImageRef)runs[row],CGRectMake(f*384+96,64,192,192));CGContextDrawImage(preview,CGRectMake(row*192,0,192,192),crop);CGImageRelease(crop);}
 CGImageRef im=CGBitmapContextCreateImage(preview);
 CGImageDestinationAddImage(gif,im,(__bridge CFDictionaryRef)@{(__bridge NSString*)kCGImagePropertyGIFDictionary:@{(__bridge NSString*)kCGImagePropertyGIFDelayTime:@.07}});
 if(f==2)save(im,@"docs/art/arka-hair/preview.png");CGImageRelease(im);
}
NSCAssert(CGImageDestinationFinalize(gif),@"GIF export failed");return 0;
}}
