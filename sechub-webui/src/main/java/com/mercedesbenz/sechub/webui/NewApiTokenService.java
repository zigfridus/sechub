package com.mercedesbenz.sechub.webui;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import reactor.core.publisher.Mono;

@Service
public class NewApiTokenService {
	@Autowired
	private WebClient webClient;
	
	// Request new API token: https://mercedes-benz.github.io/sechub/latest/sechub-restapi.html#user-requests-new-api-token
	/*
	 * curl 'https://sechub.example.com/api/anonymous/refresh/apitoken/emailAdress@test.com' -i -X POST -H 'Content-Type: application/json;charset=UTF-8'
	 */
	public String requestNewApiToken() {
		String email = "email@example.org";
		
		return webClient.
				post().
				uri("api/anonymous/refresh/apitoken/" + email).
				retrieve().
	              onStatus(HttpStatus::is4xxClientError,
	                      error -> Mono.error(new RuntimeException("API not found"))).
	              onStatus(HttpStatus::is5xxServerError,
	                      error -> Mono.error(new RuntimeException("Server is not responding"))).
	            bodyToMono(String.class).
	            block();
	             
	}
}
