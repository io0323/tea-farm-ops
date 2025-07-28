package com.teafarmops.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Spring Security設定クラス
 * アプリケーションのセキュリティ設定を管理
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

  /**
   * セキュリティフィルターチェーンを設定
   * @param http HttpSecurity
   * @return SecurityFilterChain
   * @throws Exception 例外
   */
  @Bean
  public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    http
        .authorizeHttpRequests((requests) -> requests
            .requestMatchers("/css/**", "/js/**", "/images/**", "/login").permitAll()
            .anyRequest().authenticated()
        )
        .formLogin((form) -> form
            .loginPage("/login")
            .defaultSuccessUrl("/", true)
            .permitAll()
        )
        .logout((logout) -> logout
            .logoutSuccessUrl("/login?logout")
            .permitAll()
        );

    return http.build();
  }

  /**
   * ユーザー詳細サービスを設定
   * @return UserDetailsService
   */
  @Bean
  public UserDetailsService userDetailsService() {
    UserDetails admin = User.withDefaultPasswordEncoder()
        .username("admin")
        .password("admin123")
        .roles("ADMIN")
        .build();

    UserDetails worker = User.withDefaultPasswordEncoder()
        .username("worker")
        .password("worker123")
        .roles("WORKER")
        .build();

    return new InMemoryUserDetailsManager(admin, worker);
  }
} 