package com.github.samdaniel.tcs.microservices.uniqueid.core;

import java.util.concurrent.atomic.AtomicInteger;
import io.opentracing.Scope;
import io.opentracing.Span;

public class InMemoryUniqueIdProvider implements UniqueIdProvider {

	private static AtomicInteger counter = new AtomicInteger();
	
	public Integer getUniqueId() {
		io.opentracing.Tracer tracer = Tracer.tracer();
		
		Span span = tracer.buildSpan("Generating unique Id").start();
		Scope s = tracer.scopeManager().activate(span, false);
		
		Integer uniqueId = new Integer(InMemoryUniqueIdProvider.counter.incrementAndGet());
		s.span().log("Generated uniqueId = " + uniqueId.toString());
		s.span().setTag("uniqueId", uniqueId.intValue());
		s.span().finish();
		
		return uniqueId;
	}
}
