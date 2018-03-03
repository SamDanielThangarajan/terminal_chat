package com.github.samdaniel.tcs.microservices.registry.core;

import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.github.samdaniel.tcs.microservices.registry.config.Tracer;
import com.github.samdaniel.tcs.microservices.registry.grpc.RegistryServer;
import com.github.samdaniel.tcs.microservices.registry.core.Main;

public class Main {

	private int port;
	private String protocol;
	
	private Main() throws IOException {
		// Defaults
		Tracer.Factory.create("noop");
		port = -1;
		protocol ="grpc";
	}
	
	/*
	 * Usage:
	 * java -jar protocol=<grpc|rest> port=portnumber tracingbackend=<jaeger|noop>
	 * 
	 * protocol: grpc|rest 
	 *           only grpc supported
	 * 
	 * port: integer port
	 * 
	 * tracingbacked : jaeger|noop 
	 *               : if nothing is given, noop is chosen 
	 *            
	 */
	
	private void validateArgumentFormat(String arg) throws IllegalArgumentException {
		Pattern p = Pattern.compile("[a-z]+=.+");
		Matcher m = p.matcher(arg);
		
		if (!m.find()) {
			throw new IllegalArgumentException(arg + " does not follow key=value pattern");
		}
	}
	
	private void handleArgument(String arg) throws IOException {
		String parts[] = arg.split("=");
		if (parts[0].equals("protocol")) {
			this.protocol = parts[1];
		} else if (parts[0].equals("tracingbackend")) {
			Tracer.Factory.create(parts[1]);
		} else if (parts[0].equals("port")) {
			this.port = Integer.parseInt(parts[1]);
		}
	}
	
	private void handleArguments(String[] args) throws IOException {
		for (String arg: args) {
			validateArgumentFormat(arg);
			handleArgument(arg);
		}
	}
	
	private void isAllOKToStart() {
		if (port == -1) {
			throw new IllegalArgumentException("port is not defined");
		}
	}
	
	
	
	
	public static void main(String[] args) throws IOException, InterruptedException {
		Main main = new Main();
		main.handleArguments(args);
		
		// Check Argument Values
		main.isAllOKToStart();
		
		if (main.protocol.equals("grpc")) {
			RegistryServer server = new RegistryServer(main.port);
			server.start();
		}

	}

	
	
	
}
