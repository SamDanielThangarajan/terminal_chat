package com.github.samdaniel.tcs.microservices.registry.grpc;

import org.testng.annotations.Test;

import com.github.samdaniel.tcs.microservices.registry.generated.RegistryServiceGrpc;
import com.github.samdaniel.tcs.microservices.registry.generated.RegistryServiceOuterClass.UserCheckRequest;
import com.github.samdaniel.tcs.microservices.registry.generated.RegistryServiceOuterClass.UserCheckResponse;
import com.github.samdaniel.tcs.microservices.registry.generated.RegistryServiceOuterClass.UserRegistrationRequest;
import com.github.samdaniel.tcs.microservices.registry.generated.RegistryServiceOuterClass.UserRegistrationResponse;
import com.github.samdaniel.tcs.microservices.registry.generated.RegistryServiceOuterClass.UserStatus;

import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;

import org.testng.annotations.BeforeTest;

import java.io.IOException;

import org.testng.annotations.AfterSuite;
import org.testng.annotations.BeforeSuite;

public class TestRegistryGrpcServer {

	RegistryServer server;
	RegistryServiceGrpc.RegistryServiceBlockingStub blockingStub;
	RegistryServiceGrpc.RegistryServiceStub asyncStub;
	Thread serverThread;
	int testPort = 6001;

	@BeforeSuite
	public void beforeSuite() {
		server = new RegistryServer(testPort);

		Runnable run = new Runnable() {
			@Override
			public void run() {
				try {
					server.start();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

			}

		};
		serverThread = new Thread(run);
		serverThread.start();
		
	}

	@AfterSuite
	public void afterSuite() {
		server.shutDownNow();
	}

	@BeforeTest
	public void beforeTest() {
		ManagedChannelBuilder<?> channelBuilder = ManagedChannelBuilder.forAddress("localhost", testPort).usePlaintext(true);
		ManagedChannel channel = channelBuilder.build();

		blockingStub = RegistryServiceGrpc.newBlockingStub(channel);
		asyncStub =  RegistryServiceGrpc.newStub(channel);
	}


	@Test
	public void CreateUserSuccess() {

		UserRegistrationResponse response = blockingStub.registerUser(prepareUserRegRequest("CreateUserSuccess", "CreateUserSuccess", "CreateUserSuccess"));
		assert(response.getStatus() == UserStatus.USER_CREATED);

		response = blockingStub.registerUser(prepareUserRegRequest("CreateUserSuccess1", "CreateUserSuccess1", "CreateUserSuccess1"));
		assert(response.getStatus() == UserStatus.USER_CREATED);

	}

	@Test
	public void CreateExistingUser() {

		UserRegistrationResponse response = blockingStub.registerUser(prepareUserRegRequest("CreateExistingUser", "CreateExistingUser", "CreateExistingUser"));
		assert(response.getStatus() == UserStatus.USER_CREATED);

		response = blockingStub.registerUser(prepareUserRegRequest("CreateExistingUser", "CreateExistingUser", "CreateExistingUser"));
		assert(response.getStatus() == UserStatus.USER_EXISTS);

	}
	
	@Test
	public void TestUserExists() {
		UserRegistrationResponse response = blockingStub.registerUser(prepareUserRegRequest("TestUserExists", "TestUserExists", "TestUserExists"));
		assert(response.getStatus() == UserStatus.USER_CREATED);
		
		UserCheckResponse userCheckResponse = blockingStub.isUserPresent(prepareUserCheckRequest("TestUserExists"));
		assert (true == userCheckResponse.getStatus());
		
	}
	
	@Test
	public void TestUserNotExists() {
		
		UserCheckResponse userCheckResponse = blockingStub.isUserPresent(prepareUserCheckRequest("TestUserNotExists"));
		assert (false == userCheckResponse.getStatus());

	}


	private UserRegistrationRequest prepareUserRegRequest(String name, String password, String alias) {
		return UserRegistrationRequest.newBuilder().setUserName(name).setPassword(password).setAliasName(alias).build();
	}
	
	private UserCheckRequest prepareUserCheckRequest(String name) {
		return UserCheckRequest.newBuilder().setUserName(name).build();
	}


}

