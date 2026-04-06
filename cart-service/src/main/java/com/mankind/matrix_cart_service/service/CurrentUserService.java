package com.mankind.matrix_cart_service.service;

import com.mankind.api.user.dto.UserDTO;
import com.mankind.api.user.enums.Role;
import com.mankind.matrix_cart_service.client.UserClient;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CurrentUserService {
    private final UserClient userClient;
    @Value("${app.security.oauth2.enabled:false}")
    private boolean oauth2Enabled;
    @Value("${app.security.dev-user-id:1}")
    private Long devUserId;

    public UserDTO getCurrentUser() {
        if (!oauth2Enabled) {
            UserDTO user = new UserDTO();
            user.setId(devUserId);
            user.setUsername("render-test-user");
            user.setRole(Role.CUSTOMER);
            user.setActive(true);
            return user;
        }
        return userClient.getCurrentUser();
    }

    public Long getCurrentUserId() {
        return getCurrentUser().getId();
    }
} 
