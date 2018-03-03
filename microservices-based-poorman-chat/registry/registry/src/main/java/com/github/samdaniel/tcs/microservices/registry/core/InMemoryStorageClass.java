package com.github.samdaniel.tcs.microservices.registry.core;

import java.util.HashMap;
import java.util.Map;

public final class InMemoryStorageClass extends StorageClass {

	private Map<String, UserData> userRegistry = new HashMap<String, UserData>();
	
	public InMemoryStorageClass() {}
	
	
	@Override
	public void createUser(UserData data) throws UserCreationException {
	
		if (isUserPresent(data.getuName())) {
			throw new UserCreationException("User already registered", StorageStatus.UserExists);
		}
		
		userRegistry.put(data.getuName(), data);
		
	}


	@Override
	public boolean isUserPresent(String uName) {
		return userRegistry.containsKey(uName);
	}

}
