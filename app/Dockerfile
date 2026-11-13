# Estágio 1: build da aplicação com Maven, aproveitando o cache de dependências
# Java 25: mesma versão do pom.xml da API (java.version = 25)
FROM maven:3.9.16-eclipse-temurin-25 AS builder
WORKDIR /app

# Copia o pom.xml e baixa as dependências primeiro (camada reaproveitada se só o código mudar)
COPY pom.xml .
RUN mvn dependency:go-offline

# Agora copia o código-fonte e gera o jar
COPY src ./src
RUN mvn clean package -DskipTests

# Estágio 2: imagem enxuta só com o JRE para execução
FROM eclipse-temurin:25-jre

# Cria usuário não-root antes de copiar os arquivos
RUN addgroup --system appuser && adduser --system --ingroup appuser appuser
WORKDIR /app

# Copia só o jar final do estágio de build
COPY --from=builder /app/target/*.jar app.jar
RUN chown appuser:appuser app.jar

USER appuser

# Porta da API
EXPOSE 8080

# Valores padrão não sensíveis; usuário, senha do banco e segredo JWT vêm SOMENTE do .env via Compose
ENV SERVER_PORT=8080 \
    DB_URL=jdbc:oracle:thin:@//db:1521/FREEPDB1

ENTRYPOINT ["java", "-jar", "app.jar"]
