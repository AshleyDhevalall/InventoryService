# https://hub.docker.com/_/microsoft-dotnet
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /source

COPY ["InventoryService.sln", "./"]
COPY ["InventoryService/InventoryService.csproj", "InventoryService/"]
COPY ["InventoryService.Tests/InventoryService.Tests.csproj", "InventoryService.Tests/"]

# restore for all projects
RUN dotnet restore InventoryService.sln -v:diag
COPY . .

# test
# use the label to identity this layer later
LABEL test=true

# Install Sonar Scanner, Coverlet and Java (required for Sonar Scanner)
# RUN apt-get update && apt-get install -y openjdk-11-jdk
# RUN dotnet tool install --global dotnet-sonarscanner
RUN dotnet tool install --global dotnet-reportgenerator-globaltool
ENV PATH="$PATH:/root/.dotnet/tools"

RUN dotnet publish --output /out/
RUN dotnet test "InventoryService.Tests/InventoryService.Tests.csproj" \
  /p:CollectCoverage=true \
  /p:CoverletOutputFormat=opencover \
  /p:CoverletOutput="/coverage"
  
# RUN dotnet test "InventoryService.Tests/InventoryService.Tests.csproj" --settings coverlet.runsettings --results-directory /testresults --logger "trx;LogFileName=test_results.xml" /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura /p:CoverletOutput=/testresults/coverage/ /p:Exclude="[xunit.*]*"

# generate html reports using report generator tool
# RUN reportgenerator "-reports:/*.xml" "-targetdir:/testresults" "-reporttypes:HTMLInline;HTMLChart"
 
RUN dotnet build "InventoryService/InventoryService.csproj"
  
# final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:5.0
WORKDIR /app
# Copy the build output from the SDK image
COPY --from=build /out .
ENTRYPOINT ["dotnet", "InventoryService.dll"]