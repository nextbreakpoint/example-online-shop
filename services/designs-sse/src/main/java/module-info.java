module com.nextbreakpoint.shop.designs.sse {
    requires com.nextbreakpoint.shop.common;
    requires com.fasterxml.jackson.core;
    requires com.fasterxml.jackson.databind;
    opens com.nextbreakpoint.shop.designs to com.nextbreakpoint.shop.common;
}