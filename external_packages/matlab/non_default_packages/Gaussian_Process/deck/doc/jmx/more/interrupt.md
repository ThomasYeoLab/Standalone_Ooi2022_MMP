
# Keyboard interruptions

Support for keyboard interruptions is not automatic in Mex.
We provide a simple function to manually check for interruptions.

```cpp
JMX_REJECT( jmx::interruption_pending(), "Interrupted." )
```
