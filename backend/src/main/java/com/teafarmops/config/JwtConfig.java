package com.teafarmops.config;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Component
public class JwtConfig {

  private static final Logger logger = LoggerFactory.getLogger(JwtConfig.class);

  @Value("${jwt.secret:defaultSecretKey}")
  private String secret;

  @Value("${jwt.expiration:86400000}")
  private long expiration;

  private SecretKey getSigningKey() {
    logger.info("=== JWT CONFIG: Creating signing key ===");
    logger.info("=== JWT CONFIG: Secret length: {} ===", secret.length());
    logger.info("=== JWT CONFIG: Secret bytes length: {} ===", secret.getBytes(StandardCharsets.UTF_8).length);
    
    try {
      SecretKey key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
      logger.info("=== JWT CONFIG: Signing key created successfully ===");
      return key;
    } catch (Exception e) {
      logger.error("=== JWT CONFIG: Error creating signing key: {} ===", e.getMessage());
      throw e;
    }
  }

  public String generateToken(String username) {
    logger.info("=== JWT CONFIG: Generating token for user: {} ===", username);
    
    try {
      Map<String, Object> claims = new HashMap<>();
      String token = createToken(claims, username);
      logger.info("=== JWT CONFIG: Token generated successfully for user: {} ===", username);
      return token;
    } catch (Exception e) {
      logger.error("=== JWT CONFIG: Error generating token for user {}: {} ===", username, e.getMessage());
      logger.error("=== JWT CONFIG: Exception type: {} ===", e.getClass().getSimpleName());
      logger.error("=== JWT CONFIG: Exception stack trace: ===", e);
      throw e;
    }
  }

  private String createToken(Map<String, Object> claims, String subject) {
    logger.info("=== JWT CONFIG: Creating token for subject: {} ===", subject);
    logger.info("=== JWT CONFIG: Expiration time: {} ms ===", expiration);
    
    try {
      SecretKey signingKey = getSigningKey();
      logger.info("=== JWT CONFIG: Using signing key algorithm: {} ===", signingKey.getAlgorithm());
      
      String token = Jwts.builder()
          .setClaims(claims)
          .setSubject(subject)
          .setIssuedAt(new Date(System.currentTimeMillis()))
          .setExpiration(new Date(System.currentTimeMillis() + expiration))
          .signWith(signingKey, SignatureAlgorithm.HS256)
          .compact();
      
      logger.info("=== JWT CONFIG: Token created successfully ===");
      return token;
    } catch (Exception e) {
      logger.error("=== JWT CONFIG: Error creating token: {} ===", e.getMessage());
      logger.error("=== JWT CONFIG: Exception type: {} ===", e.getClass().getSimpleName());
      logger.error("=== JWT CONFIG: Exception stack trace: ===", e);
      throw e;
    }
  }

  public String extractUsername(String token) {
    return extractClaim(token, Claims::getSubject);
  }

  public Date extractExpiration(String token) {
    return extractClaim(token, Claims::getExpiration);
  }

  public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
    final Claims claims = extractAllClaims(token);
    return claimsResolver.apply(claims);
  }

  private Claims extractAllClaims(String token) {
    return Jwts.parserBuilder()
        .setSigningKey(getSigningKey())
        .build()
        .parseClaimsJws(token)
        .getBody();
  }

  private Boolean isTokenExpired(String token) {
    return extractExpiration(token).before(new Date());
  }

  public Boolean validateToken(String token, String username) {
    final String extractedUsername = extractUsername(token);
    return (extractedUsername.equals(username) && !isTokenExpired(token));
  }
} 