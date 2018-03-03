package com.github.samdaniel.tcs.microservices.registry.core;

public abstract class StorageClass {

	public abstract void createUser(UserData data) throws UserCreationException ;
	
	public abstract boolean isUserPresent(String uName);
	
	public static enum StorageStatus{
		UserCreated,
		UserExists,
		NoSuchUser,
		StorageFailure
	}
	
	public static class UserCreationException extends Exception {
		
		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;

		StorageClass.StorageStatus reason;
		
		public UserCreationException(String message) {
			super(message);
		}
		
		public UserCreationException(String message, StorageClass.StorageStatus reason) {
			super(message);
			this.reason = reason;
		}
		
		public StorageClass.StorageStatus getReason() {
			return reason;
		}

	}




}
