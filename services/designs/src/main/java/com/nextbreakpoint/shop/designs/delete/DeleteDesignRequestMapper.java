package com.nextbreakpoint.shop.designs.delete;

import com.nextbreakpoint.shop.common.RequestMapper;
import io.vertx.rxjava.ext.web.RoutingContext;

import java.util.UUID;

public class DeleteDesignRequestMapper implements RequestMapper<DeleteDesignRequest> {
    @Override
    public DeleteDesignRequest apply(RoutingContext context) {
        final String uuid = context.request().getParam("param0");

        return new DeleteDesignRequest(UUID.fromString(uuid));
    }
}