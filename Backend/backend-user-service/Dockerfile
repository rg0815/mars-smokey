﻿FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["backend-user-service/backend-user-service.csproj", "backend-user-service/"]
RUN dotnet restore "backend-user-service/backend-user-service.csproj"
COPY . .
WORKDIR "/src/backend-user-service"
RUN dotnet build "backend-user-service.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "backend-user-service.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "backend-user-service.dll"]
