package com.nextbreakpoint.shop.designs.controllers.delete;

import com.nextbreakpoint.shop.common.model.Mapper;
import com.nextbreakpoint.shop.common.model.Message;
import com.nextbreakpoint.shop.common.model.MessageType;
import com.nextbreakpoint.shop.common.model.events.DeleteDesignsEvent;
import io.vertx.core.json.Json;

import java.util.Objects;
import java.util.UUID;

public class DeleteDesignsMessageMapper implements Mapper<DeleteDesignsEvent, Message> {
    private final String messageSource;

    public DeleteDesignsMessageMapper(String messageSource) {
        this.messageSource = Objects.requireNonNull(messageSource);
    }

    @Override
    public Message transform(DeleteDesignsEvent event) {
        return new Message(UUID.randomUUID().toString(), MessageType.DESIGNS_DELETE, Json.encode(event), messageSource, new UUID(0,0).toString(), System.currentTimeMillis());
    }
}
