module com.nextbreakpoint.shop.auth {
    requires com.nextbreakpoint.shop.common;
    requires com.fasterxml.jackson.core;
    requires com.fasterxml.jackson.databind;
    opens com.nextbreakpoint.shop.auth to com.nextbreakpoint.shop.common;
}