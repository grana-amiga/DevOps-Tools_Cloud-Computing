# Estágio 1: build da aplicação com Maven, aproveitando o cache de dependências
FROM maven:3.9.9-eclipse-temurin-21 AS builder
WORKDIR /app

# Copia o pom.xml e baixa as dependências primeiro (camada reaproveitada se só o código mudar)
COPY pom.xml .
RUN mvn dependency:go-offline

# Agora copia o código-fonte e gera o jar
COPY src ./src
RUN mvn clean package -DskipTests

# Estágio 2: imagem enxuta só com o JRE para execução
FROM eclipse-temurin:21-jre

# Cria usuário não-root antes de copiar os arquivos
RUN addgroup --system appuser && adduser --system --ingroup appuser appuser
WORKDIR /app

# Copia só o jar final do estágio de build
COPY --from=builder /app/target/*.jar app.jar
RUN chown appuser:appuser app.jar

USER appuser

# Porta da API
EXPOSE 8080

# Valores padrão não sensíveis; usuário e senha do banco vêm SOMENTE do .env via Compose
ENV SERVER_PORT=8080 \
    SPRING_DATASOURCE_URL=jdbc:postgresql://db:5432/granaamiga

ENTRYPOINT ["java", "-jar", "app.jar"]
