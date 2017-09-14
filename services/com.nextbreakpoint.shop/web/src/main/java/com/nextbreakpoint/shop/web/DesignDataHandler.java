package com.nextbreakpoint.shop.web;

import com.nextbreakpoint.shop.common.Authentication;
import com.nextbreakpoint.shop.common.Design;
import com.nextbreakpoint.shop.common.Failure;
import com.nextbreakpoint.shop.common.Headers;
import io.vertx.core.Handler;
import io.vertx.core.json.JsonObject;
import io.vertx.rxjava.core.buffer.Buffer;
import io.vertx.rxjava.ext.web.RoutingContext;
import io.vertx.rxjava.ext.web.client.HttpRequest;
import io.vertx.rxjava.ext.web.client.HttpResponse;
import io.vertx.rxjava.ext.web.client.WebClient;

import java.text.SimpleDateFormat;
import java.util.Date;

import static com.nextbreakpoint.shop.common.ContentType.APPLICATION_JSON;
import static com.nextbreakpoint.shop.common.Headers.ACCEPT;
import static com.nextbreakpoint.shop.common.Headers.AUTHORIZATION;
import static com.nextbreakpoint.shop.common.Headers.MODIFIED;
import static com.nextbreakpoint.shop.common.TimeUtil.TIMESTAMP_PATTERN;

public class DesignDataHandler implements Handler<RoutingContext> {
    private final WebClient client;
    private final String webUrl;
    private final String designsUrl;

    public DesignDataHandler(WebClient client, JsonObject config) {
        this.client = client;
        this.webUrl = config.getString("web_url");
        this.designsUrl = config.getString("designs_url");
    }

    public void handle(RoutingContext routingContext) {
        final String token = Authentication.getToken(routingContext);

        final String uuid = routingContext.pathParam("param0");

        final HttpRequest<Buffer> request = client.get("/designs/" + uuid);

        if (token != null) {
            request.putHeader(AUTHORIZATION, token);
        }

        request.putHeader(ACCEPT, APPLICATION_JSON).rxSend()
              .subscribe(response -> handleDesign(routingContext, response), e -> routingContext.fail(Failure.requestFailed(e)));
    }

    private void handleDesign(RoutingContext routingContext, HttpResponse<Buffer> response) {
        try {
            final JsonObject jsonObject = response.bodyAsJsonObject();

            final String updated = jsonObject.getString("updated");

            final String created = jsonObject.getString("created");

            final String manifest = jsonObject.getString("manifest");

            final String metadata = jsonObject.getString("metadata");

            final String script = jsonObject.getString("script");

            final Design object = makeDesign(jsonObject.getString("uuid"), created, updated, manifest, metadata, script);

            final String modified = response.getHeader(MODIFIED);

            final SimpleDateFormat df = new SimpleDateFormat(TIMESTAMP_PATTERN);

            routingContext.put("modified", df.format(new Date(Long.parseLong(modified))));

            routingContext.put("offset", modified);

            routingContext.put("design", object);

            routingContext.next();
        } catch (Exception e) {
            e.printStackTrace();

            routingContext.fail(Failure.requestFailed(e));
        }
    }

    private Design makeDesign(String uuid, String created, String modified, String manifest, String metadata, String script) {
        return new Design(uuid, webUrl + "/content/designs/" + uuid, designsUrl + "/designs/" + uuid + "/0/0/0/512.png", created, modified, manifest, metadata, script);
    }

    public static DesignDataHandler create(WebClient client, JsonObject config) {
        return new DesignDataHandler(client, config);
    }
}