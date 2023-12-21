#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "AudioRecorder.h"

#import <MicrosoftCognitiveServicesSpeech/SPXSpeechApi.h>


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;

      FlutterMethodChannel* recognizeChannel = [FlutterMethodChannel
                                              methodChannelWithName:@"azure_tts_flutter"
                                              binaryMessenger:controller.binaryMessenger];

    __weak typeof(self) weakSelf = self;
    
    [recognizeChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
      // This method is invoked on the UI thread.
      if ([@"startRecognize" isEqualToString:call.method]) {
          
          NSLog(@"call method in oc");
        NSString *key = call.arguments[@"key"];
        NSString *region = call.arguments[@"region"];
        NSString *lang = call.arguments[@"lang"];

        [weakSelf startRecognize:key:region:lang];

        
          
          
      } else {
        result(FlutterMethodNotImplemented);
      }
    }];

    
    
    
    
    
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}


- (int)getBatteryLevel {
  UIDevice* device = UIDevice.currentDevice;
  device.batteryMonitoringEnabled = YES;
  if (device.batteryState == UIDeviceBatteryStateUnknown) {
    return -1;
  } else {
    return (int)(device.batteryLevel * 100);
  }
}

- (void)startRecognize: (NSString *) key : (NSString *) region : (NSString *) lang {
    SPXSpeechConfiguration *speechConfig = [[SPXSpeechConfiguration alloc] initWithSubscription:key region:region];
    if (!speechConfig) {
        NSLog(@"Could not load speech config");
        return;
    }
    NSLog(@"start recognize lineeeeee");
    // speechConfig.speechRecognitionLanguage = @"zh-CN";
    
    // SPXSpeechRecognizer* speechRecognizer = [[SPXSpeechRecognizer alloc] init:speechConfig];
    
    
    
    
    
    
    // should handle here
    SPXPushAudioInputStream *stream = [[SPXPushAudioInputStream alloc] init];
    AudioRecorder *recorder = [[AudioRecorder alloc]initWithPushStream:stream];
    SPXAudioConfiguration *audioConfig = [[SPXAudioConfiguration alloc]initWithStreamInput:stream];

    SPXSpeechRecognizer* speechRecognizer = [[SPXSpeechRecognizer alloc] initWithSpeechConfiguration:speechConfig language:lang audioConfiguration:audioConfig];
    if (!speechRecognizer) {
        NSLog(@"Could not create speech recognizer");
        return;
    }
    
    // create pronunciation assessment config, set grading system, granularity and if enable miscue based on your requirement.
//        SPXPronunciationAssessmentConfiguration *pronunicationConfig =
//        [[SPXPronunciationAssessmentConfiguration alloc] init:@"测试音频内容"
//                                                gradingSystem:SPXPronunciationAssessmentGradingSystem_HundredMark
//                                                  granularity:SPXPronunciationAssessmentGranularity_Phoneme
//                                                 enableMiscue:true];
//        
//        [pronunicationConfig enableProsodyAssessment];
//        [pronunicationConfig applyToRecognizer:speechRecognizer];
    
        [recorder record];
        // [speechRecognizer startContinuousRecognition];
    // end handle
    
//    SPXSpeechRecognitionResult *speechResult = [speechRecognizer recognizeOnce];
//    if (SPXResultReason_RecognizedSpeech == speechResult.reason) {
//        NSLog(@"Speech recognition result received: %@", speechResult.text);
//    }
    
    
    if (!speechRecognizer) {
        NSLog(@"Could not create speech recognizer");
        return;
    }
    
    [speechRecognizer addRecognizingEventHandler: ^ (SPXSpeechRecognizer *recognizer, SPXSpeechRecognitionEventArgs *eventArgs) {
           NSLog(@"Received intermediate result event. SessionId: %@, recognition result:%@. Status %ld. offset %llu duration %llu resultid:%@", eventArgs.sessionId, eventArgs.result.text, (long)eventArgs.result.reason, eventArgs.result.offset, eventArgs.result.duration, eventArgs.result.resultId);
       }];
    
    [speechRecognizer addRecognizedEventHandler: ^ (SPXSpeechRecognizer *recognizer, SPXSpeechRecognitionEventArgs *eventArgs) {
            NSLog(@"Received final result event. SessionId: %@, recognition result:%@. Status %ld. offset %llu duration %llu resultid:%@", eventArgs.sessionId, eventArgs.result.text, (long)eventArgs.result.reason, eventArgs.result.offset, eventArgs.result.duration, eventArgs.result.resultId);
        
        // ...
        }];
    
    __block bool end = false;
    [speechRecognizer addSessionStoppedEventHandler: ^ (SPXRecognizer *recognizer, SPXSessionEventArgs *eventArgs) {
            NSLog(@"Received session stopped event. SessionId: %@", eventArgs.sessionId);
        end = true;
        }];
    
     [speechRecognizer startContinuousRecognition];
    
    
    
    
    
    
    
    
    while (end == false) {
        [NSThread sleepForTimeInterval:6.0f];
        [speechRecognizer stopContinuousRecognition];
    }
    
    
    
            
        // [speechRecognizer stopContinuousRecognition];
    
    
    
//    SPXSpeechRecognitionResult *speechResult = [speechRecognizer recognizeOnce];
//    
//    if (SPXResultReason_RecognizedSpeech == speechResult.reason) {
//        NSLog(@"Speech recognition result received: %@", speechResult.text);
//    }
    
    
}


@end
