package com.teafarmops.controllers;

import com.teafarmops.config.JwtConfig;
import com.teafarmops.dto.LoginRequest;
import com.teafarmops.dto.LoginResponse;
import com.teafarmops.dto.UserDto;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

  private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

  @Autowired
  private AuthenticationManager authenticationManager;

  @Autowired
  private JwtConfig jwtConfig;

  @PostMapping("/login")
  public ResponseEntity<?> login(@Valid @RequestBody LoginRequest loginRequest) {
    logger.info("=== AUTH CONTROLLER: LOGIN ATTEMPT START ===");
    logger.info("=== AUTH CONTROLLER: Login attempt for user: {} ===", loginRequest.getUsername());
    logger.info("=== AUTH CONTROLLER: Password length: {} ===", loginRequest.getPassword() != null ? loginRequest.getPassword().length() : "null");
    
    try {
      logger.info("=== AUTH CONTROLLER: Creating authentication token... ===");
      UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
          loginRequest.getUsername(),
          loginRequest.getPassword()
      );
      logger.info("=== AUTH CONTROLLER: Authentication token created for user: {} ===", authToken.getName());
      logger.info("=== AUTH CONTROLLER: Authentication token details: name={}, credentials={}, authorities={} ===", 
          authToken.getName(), 
          authToken.getCredentials() != null ? "present" : "null", 
          authToken.getAuthorities());
      
      logger.info("=== AUTH CONTROLLER: AuthenticationManager instance: {} ===", authenticationManager.getClass().getSimpleName());
      logger.info("=== AUTH CONTROLLER: Attempting authentication with AuthenticationManager... ===");
      
      Authentication authentication = authenticationManager.authenticate(authToken);
      logger.info("=== AUTH CONTROLLER: Authentication successful for user: {} ===", authentication.getName());
      logger.info("=== AUTH CONTROLLER: Authentication details: name={}, authorities={}, authenticated={} ===", 
          authentication.getName(), 
          authentication.getAuthorities(), 
          authentication.isAuthenticated());

      UserDetails userDetails = (UserDetails) authentication.getPrincipal();
      logger.info("=== AUTH CONTROLLER: UserDetails retrieved: {} ===", userDetails.getUsername());
      logger.info("=== AUTH CONTROLLER: User authorities: {} ===", userDetails.getAuthorities());
      
      logger.info("=== AUTH CONTROLLER: Generating JWT token... ===");
      String token = jwtConfig.generateToken(userDetails.getUsername());
      logger.info("=== AUTH CONTROLLER: JWT token generated successfully ===");

      UserDto user = new UserDto();
      user.setUsername(userDetails.getUsername());
      user.setRole(userDetails.getAuthorities().stream()
          .findFirst()
          .map(authority -> authority.getAuthority().replace("ROLE_", ""))
          .orElse("USER"));

      LoginResponse response = new LoginResponse();
      response.setToken(token);
      response.setUser(user);
      
      logger.info("=== AUTH CONTROLLER: Login successful for user: {} ===", userDetails.getUsername());
      logger.info("=== AUTH CONTROLLER: LOGIN ATTEMPT SUCCESS ===");
      return ResponseEntity.ok(response);
    } catch (BadCredentialsException e) {
      logger.error("=== AUTH CONTROLLER: LOGIN ATTEMPT FAILED - BAD CREDENTIALS ===");
      logger.error("=== AUTH CONTROLLER: Bad credentials for user: {} ===", loginRequest.getUsername());
      logger.error("=== AUTH CONTROLLER: Exception message: {} ===", e.getMessage());
      logger.error("=== AUTH CONTROLLER: Exception stack trace: ===", e);
      Map<String, Object> errorResponse = new HashMap<>();
      errorResponse.put("message", "Invalid credentials");
      errorResponse.put("status", "error");
      return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(errorResponse);
    } catch (Exception e) {
      logger.error("=== AUTH CONTROLLER: LOGIN ATTEMPT FAILED - GENERAL ERROR ===");
      logger.error("=== AUTH CONTROLLER: Login error for user: {} - {} ===", loginRequest.getUsername(), e.getMessage());
      logger.error("=== AUTH CONTROLLER: Exception type: {} ===", e.getClass().getSimpleName());
      logger.error("=== AUTH CONTROLLER: Exception stack trace: ===", e);
      Map<String, Object> errorResponse = new HashMap<>();
      errorResponse.put("message", "Authentication failed");
      errorResponse.put("status", "error");
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
    }
  }

  @GetMapping("/me")
  public ResponseEntity<UserDto> getCurrentUser(Authentication authentication) {
    if (authentication == null) {
      return ResponseEntity.status(401).build();
    }

    UserDetails userDetails = (UserDetails) authentication.getPrincipal();
    UserDto user = new UserDto();
    user.setUsername(userDetails.getUsername());
    user.setRole(userDetails.getAuthorities().stream()
        .findFirst()
        .map(authority -> authority.getAuthority().replace("ROLE_", ""))
        .orElse("USER"));

    return ResponseEntity.ok(user);
  }

  @PostMapping("/logout")
  public ResponseEntity<String> logout() {
    return ResponseEntity.ok("Logged out successfully");
  }

  @GetMapping("/test")
  public ResponseEntity<Map<String, Object>> test() {
    logger.info("Auth test endpoint called");

    Map<String, Object> response = new HashMap<>();
    response.put("message", "Auth controller is working");
    response.put("status", "success");
    response.put("timestamp", System.currentTimeMillis());

    return ResponseEntity.ok(response);
  }
} 