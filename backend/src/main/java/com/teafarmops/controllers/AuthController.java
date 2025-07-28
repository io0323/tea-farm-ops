package com.teafarmops.controllers;

import com.teafarmops.config.JwtConfig;
import com.teafarmops.dto.LoginRequest;
import com.teafarmops.dto.LoginResponse;
import com.teafarmops.dto.UserDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

/**
 * 認証コントローラー
 * ログイン・ログアウト・ユーザー情報取得のAPI
 */
@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

  @Autowired
  private AuthenticationManager authenticationManager;

  @Autowired
  private JwtConfig jwtConfig;

  /**
   * ログイン
   * @param loginRequest ログインリクエスト
   * @return ログインレスポンス（JWTトークン含む）
   */
  @PostMapping("/login")
  public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest loginRequest) {
    try {
      Authentication authentication = authenticationManager.authenticate(
          new UsernamePasswordAuthenticationToken(
              loginRequest.getUsername(),
              loginRequest.getPassword()
          )
      );

      UserDetails userDetails = (UserDetails) authentication.getPrincipal();
      String token = jwtConfig.generateToken(userDetails.getUsername());

      UserDto user = new UserDto();
      user.setUsername(userDetails.getUsername());
      user.setRole(userDetails.getAuthorities().stream()
          .findFirst()
          .map(authority -> authority.getAuthority().replace("ROLE_", ""))
          .orElse("USER"));

      LoginResponse response = new LoginResponse();
      response.setToken(token);
      response.setUser(user);

      return ResponseEntity.ok(response);
    } catch (Exception e) {
      return ResponseEntity.badRequest().build();
    }
  }

  /**
   * 現在のユーザー情報を取得
   * @param authentication 認証情報
   * @return ユーザー情報
   */
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

  /**
   * ログアウト
   * @return 成功レスポンス
   */
  @PostMapping("/logout")
  public ResponseEntity<String> logout() {
    // JWTはステートレスなので、クライアント側でトークンを削除する
    return ResponseEntity.ok("Logged out successfully");
  }
} 