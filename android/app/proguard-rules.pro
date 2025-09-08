-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.**
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }

-keep class com.example.health_care.** { *; }