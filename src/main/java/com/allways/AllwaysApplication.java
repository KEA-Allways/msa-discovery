package com.allways;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

@EnableEurekaServer
@SpringBootApplication
public class AllwaysApplication {

	public static void main(String[] args) {
		SpringApplication.run(AllwaysApplication.class, args);
	}

}
