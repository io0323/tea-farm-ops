package com.teafarmops.config;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

/**
 * JWT認証設定クラス
 * JWTトークンの生成・検証を管理
 */
@Component
public class JwtConfig {

  @Value("${jwt.secret:defaultSecretKey}")
  private String secret;

  @Value("${jwt.expiration:86400000}")
  private long expiration;

  private SecretKey getSigningKey() {
    return Keys.hmacShaKeyFor(secret.getBytes());
  }

  /**
   * ユーザー名からJWTトークンを生成
   * @param username ユーザー名
   * @return JWTトークン
   */
  public String generateToken(String username) {
    Map<String, Object> claims = new HashMap<>();
    return createToken(claims, username);
  }

  /**
   * JWTトークンを作成
   * @param claims クレーム
   * @param subject サブジェクト（ユーザー名）
   * @return JWTトークン
   */
  private String createToken(Map<String, Object> claims, String subject) {
    return Jwts.builder()
        .setClaims(claims)
        .setSubject(subject)
        .setIssuedAt(new Date(System.currentTimeMillis()))
        .setExpiration(new Date(System.currentTimeMillis() + expiration))
        .signWith(getSigningKey(), SignatureAlgorithm.HS256)
        .compact();
  }

  /**
   * トークンからユーザー名を取得
   * @param token JWTトークン
   * @return ユーザー名
   */
  public String extractUsername(String token) {
    return extractClaim(token, Claims::getSubject);
  }

  /**
   * トークンの有効期限を取得
   * @param token JWTトークン
   * @return 有効期限
   */
  public Date extractExpiration(String token) {
    return extractClaim(token, Claims::getExpiration);
  }

  /**
   * トークンからクレームを取得
   * @param token JWTトークン
   * @param claimsResolver クレーム解決関数
   * @return クレーム
   */
  public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
    final Claims claims = extractAllClaims(token);
    return claimsResolver.apply(claims);
  }

  /**
   * トークンから全クレームを取得
   * @param token JWTトークン
   * @return 全クレーム
   */
  private Claims extractAllClaims(String token) {
    return Jwts.parserBuilder()
        .setSigningKey(getSigningKey())
        .build()
        .parseClaimsJws(token)
        .getBody();
  }

  /**
   * トークンが有効期限切れかチェック
   * @param token JWTトークン
   * @return 有効期限切れの場合true
   */
  private Boolean isTokenExpired(String token) {
    return extractExpiration(token).before(new Date());
  }

  /**
   * トークンの有効性を検証
   * @param token JWTトークン
   * @param username ユーザー名
   * @return 有効な場合true
   */
  public Boolean validateToken(String token, String username) {
    final String extractedUsername = extractUsername(token);
    return (extractedUsername.equals(username) && !isTokenExpired(token));
  }
} 