package com.mankind.matrix_product_service.config;

import feign.FeignException;
import feign.codec.ErrorDecoder;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

public class CustomErrorDecoder implements ErrorDecoder {

    @Override
    public Exception decode(String methodKey, feign.Response response) {
        switch (response.status()) {
            case 400:
                return new ResponseStatusException(HttpStatus.BAD_REQUEST, "Bad request to user service");
            case 401:
                return new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Unauthorized access to user service");
            case 403:
                return new ResponseStatusException(HttpStatus.FORBIDDEN, "Forbidden access to user service");
            case 404:
                return new ResponseStatusException(HttpStatus.NOT_FOUND, "User service endpoint not found");
            case 500:
                return new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "User service internal error");
            default:
                return FeignException.errorStatus(methodKey, response);
        }
    }
} 