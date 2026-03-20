package com.mankind.matrix_coupon_service.config;

import feign.FeignException;
import feign.codec.ErrorDecoder;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

@Slf4j
@Component
public class CustomErrorDecoder implements ErrorDecoder {
    @Override
    public Exception decode(String methodKey, feign.Response response) {
        log.error("Feign client error for method: {}, status: {}, reason: {}", 
                methodKey, response.status(), response.reason());
        switch (response.status()) {
            case 400:
                return new ResponseStatusException(HttpStatus.BAD_REQUEST, "Bad request to user service");
            case 401:
                return new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Unauthorized to user service");
            case 403:
                return new ResponseStatusException(HttpStatus.FORBIDDEN, "Forbidden to user service");
            case 404:
                return new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found");
            default:
                return new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "User service error");
        }
    }
}