package com.mankind.mankindmatrixuserservice;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest(properties = {
    "spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.security.oauth2.resource.OAuth2ResourceServerAutoConfiguration"
})
class MankindMatrixUserServiceApplicationTests {

    @Test
    void contextLoads() {
    }

}
