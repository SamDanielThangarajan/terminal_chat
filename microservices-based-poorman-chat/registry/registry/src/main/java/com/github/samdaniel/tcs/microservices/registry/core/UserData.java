package com.github.samdaniel.tcs.microservices.registry.core;

import com.github.samdaniel.tcs.microservices.registry.generated.RegistryServiceOuterClass.UserRegistrationRequest;

public class UserData {
	
	private String uName;
	private String pWord;
	private String alias;
	
	public UserData(String uname, String pword, String alias) {
		uName = uname;
		pWord = pword;
		this.alias = alias;
	}
	
	public String getuName() {
		return uName;
	}

	public String getpWord() {
		return pWord;
	}

	public String getAlias() {
		return alias;
	}

	public static class Factory {
		public UserData create(UserRegistrationRequest request) {
			return new UserData(request.getUserName(), request.getPassword(), request.getAliasName());
		}
	}

}
