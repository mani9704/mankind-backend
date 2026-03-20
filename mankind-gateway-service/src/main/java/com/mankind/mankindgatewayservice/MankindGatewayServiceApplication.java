package com.mankind.mankindgatewayservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
//@EnableDiscoveryClient
public class MankindGatewayServiceApplication {

	public static void main(String[] args) {
		SpringApplication.run(MankindGatewayServiceApplication.class, args);
	}

}
