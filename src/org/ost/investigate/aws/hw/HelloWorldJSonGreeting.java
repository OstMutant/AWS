package org.ost.investigate.aws.hw;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestStreamHandler;
import org.json.simple.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;

public class HelloWorldJSonGreeting implements RequestStreamHandler {
    public void handleRequest(InputStream inputStream, OutputStream outputStream, Context context) throws IOException {

        LambdaLogger logger = context.getLogger();
        logger.log("Loading Java Lambda handler of ProxyWithStream");
        OutputStreamWriter writer = new OutputStreamWriter(outputStream, "UTF-8");

        JSONObject responseBody = new JSONObject();
        responseBody.put("greeting","Hi!");


        JSONObject responseJson = new JSONObject();
        JSONObject headerJson = new JSONObject();
        headerJson.put("x-custom-header", "my custom header value");

        responseJson.put("isBase64Encoded", false);
        responseJson.put("statusCode", "200");
        responseJson.put("headers", headerJson);
        responseJson.put("body", responseBody.toString());
        writer.write(responseJson.toJSONString());
        writer.close();

    }
}
