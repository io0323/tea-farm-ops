package com.teafarmops.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

  private static final Logger logger = LoggerFactory.getLogger(SecurityConfig.class);

  @Bean
  public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    logger.info("=== SECURITY CONFIG: Configuring security filter chain ===");
    
    http
        .cors(cors -> cors.configurationSource(corsConfigurationSource()))
        .csrf(csrf -> csrf.disable())
        .authorizeHttpRequests((requests) -> requests
            .anyRequest().permitAll()
        )
        .authenticationProvider(authenticationProvider())
        .httpBasic(basic -> basic.disable())
        .formLogin(form -> form.disable());

    logger.info("=== SECURITY CONFIG: Security filter chain configured successfully ===");
    return http.build();
  }

  @Bean
  public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
    logger.info("=== SECURITY CONFIG: Creating AuthenticationManager ===");
    return config.getAuthenticationManager();
  }

  @Bean
  public AuthenticationProvider authenticationProvider() {
    logger.info("=== SECURITY CONFIG: Creating AuthenticationProvider ===");
    
    DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
    authProvider.setUserDetailsService(userDetailsService());
    authProvider.setPasswordEncoder(passwordEncoder());
    authProvider.setHideUserNotFoundExceptions(false);
    
    logger.info("=== SECURITY CONFIG: AuthenticationProvider created successfully ===");
    return authProvider;
  }

  @Bean
  public UserDetailsService userDetailsService() {
    logger.info("=== SECURITY CONFIG: Creating UserDetailsService ===");
    
    String adminPassword = passwordEncoder().encode("admin123");
    String userPassword = passwordEncoder().encode("user123");
    
    logger.info("=== SECURITY CONFIG: Encoded admin password: {} ===", adminPassword);
    logger.info("=== SECURITY CONFIG: Encoded user password: {} ===", userPassword);
    
    UserDetails admin = User.builder()
        .username("admin")
        .password(adminPassword)
        .roles("ADMIN")
        .build();
    
    UserDetails user = User.builder()
        .username("user")
        .password(userPassword)
        .roles("USER")
        .build();
    
    logger.info("=== SECURITY CONFIG: Created users: admin (ADMIN), user (USER) ===");
    
    return new InMemoryUserDetailsManager(admin, user);
  }

  @Bean
  public PasswordEncoder passwordEncoder() {
    logger.info("=== SECURITY CONFIG: Creating PasswordEncoder ===");
    return new BCryptPasswordEncoder();
  }

  @Bean
  public CorsConfigurationSource corsConfigurationSource() {
    logger.info("=== SECURITY CONFIG: Creating CORS configuration ===");
    
    CorsConfiguration configuration = new CorsConfiguration();
    configuration.setAllowedOriginPatterns(Arrays.asList("*"));
    configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
    configuration.setAllowedHeaders(Arrays.asList("*"));
    configuration.setAllowCredentials(true);
    configuration.setMaxAge(3600L);
    
    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", configuration);
    
    logger.info("=== SECURITY CONFIG: CORS configuration created successfully ===");
    return source;
  }
} 