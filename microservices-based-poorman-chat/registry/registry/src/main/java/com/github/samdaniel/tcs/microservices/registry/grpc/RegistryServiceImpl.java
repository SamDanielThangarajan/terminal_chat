/**
 * 
 */
package com.github.samdaniel.tcs.microservices.registry.grpc;

import static io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall;

import com.github.samdaniel.tcs.microservices.registry.core.StorageClass;
import com.github.samdaniel.tcs.microservices.registry.core.StorageClass.UserCreationException;
import com.github.samdaniel.tcs.microservices.registry.core.UserData;
import com.github.samdaniel.tcs.microservices.registry.generated.RegistryServiceGrpc.RegistryServiceImplBase;
import com.github.samdaniel.tcs.microservices.registry.generated.RegistryServiceOuterClass.UserCheckRequest;
import com.github.samdaniel.tcs.microservices.registry.generated.RegistryServiceOuterClass.UserCheckResponse;
import com.github.samdaniel.tcs.microservices.registry.generated.RegistryServiceOuterClass.UserRegistrationRequest;
import com.github.samdaniel.tcs.microservices.registry.generated.RegistryServiceOuterClass.UserRegistrationResponse;
import com.github.samdaniel.tcs.microservices.registry.generated.RegistryServiceOuterClass.UserStatus;

/**
 * @author edansam
 *
 */
public class RegistryServiceImpl extends RegistryServiceImplBase {
	
	private StorageClass storage;
	
	public RegistryServiceImpl(StorageClass storage) {
		this.storage = storage;
	}
	
	private UserStatus mapReasonToStatus(StorageClass.StorageStatus reason) {

		switch (reason) {
		case UserExists:
			return UserStatus.USER_EXISTS;
		default:
			return UserStatus.USER_CREATION_FAILED;
		}

	} 
	
    public void registerUser(UserRegistrationRequest request, io.grpc.stub.StreamObserver<UserRegistrationResponse> responseObserver) {
    	UserData uData = new UserData.Factory().create(request);
    
    	UserStatus status = UserStatus.USER_CREATED;
    	String additionalInfo = "";
    	
    	try {
			storage.createUser(uData);
		} catch (UserCreationException e) {
			status = this.mapReasonToStatus(e.getReason());
			additionalInfo = e.getMessage();
		}
    	
    	UserRegistrationResponse response = UserRegistrationResponse.newBuilder().setStatus(status).setAdditionalInformation(additionalInfo).build();
    	responseObserver.onNext(response);
    	responseObserver.onCompleted();

    }
    
    public void isUserPresent(UserCheckRequest request, io.grpc.stub.StreamObserver<UserCheckResponse> responseObserver)  {
    	boolean output = storage.isUserPresent(request.getUserName());
    	
    	UserCheckResponse response = UserCheckResponse.newBuilder().setStatus(output).build();
    	
    	responseObserver.onNext(response);
    	responseObserver.onCompleted();

    }
}
