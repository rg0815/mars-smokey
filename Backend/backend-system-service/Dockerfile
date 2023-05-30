FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["backend-system-service/backend-system-service.csproj", "backend-system-service/"]
RUN dotnet restore "backend-system-service/backend-system-service.csproj"
COPY . .
WORKDIR "/src/backend-system-service"
RUN dotnet build "backend-system-service.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "backend-system-service.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "backend-system-service.dll"]
