package com.allways;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

//유레카 ok
@EnableEurekaServer
@SpringBootApplication
public class AllwaysApplication {

	public static void main(String[] args) {

		SpringApplication.run(AllwaysApplication.class, args);
	}

}
