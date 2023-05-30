FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["backend-notification-service/backend-notification-service.csproj", "backend-notification-service/"]
RUN dotnet restore "backend-notification-service/backend-notification-service.csproj"
COPY . .
WORKDIR "/src/backend-notification-service"
RUN dotnet build "backend-notification-service.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "backend-notification-service.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "backend-notification-service.dll"]
