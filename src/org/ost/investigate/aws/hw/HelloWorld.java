package org.ost.investigate.aws.hw;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class HelloWorld implements RequestHandler<String,String> {
    public String handleRequest(String s, Context context) {
        context.getLogger().log("Input: " + s);
        return String.format("Hello World snd %s", s);
    }
}
