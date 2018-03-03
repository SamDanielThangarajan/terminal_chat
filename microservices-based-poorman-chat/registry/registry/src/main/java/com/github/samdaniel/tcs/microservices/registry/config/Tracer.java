package com.github.samdaniel.tcs.microservices.registry.config;

import java.io.IOException;
import com.uber.jaeger.Configuration;
import com.uber.jaeger.samplers.ProbabilisticSampler;

import io.opentracing.noop.NoopTracerFactory;

public class Tracer {
	private static io.opentracing.Tracer tracer = NoopTracerFactory.create();
	
	
	public static class Factory {
		public static void create(String traceBackend) throws IOException {
			if (traceBackend.equals("jaeger")) {
				com.uber.jaeger.Tracer tr = (com.uber.jaeger.Tracer)new Configuration("registry-service",
			    		new Configuration.SamplerConfiguration(ProbabilisticSampler.TYPE, 1),
			    		new Configuration.ReporterConfiguration()).getTracer();
				Tracer.setTracer(tr);
				
			} else if (traceBackend.equals("noop")) {
				Tracer.setTracer(NoopTracerFactory.create());
			} else {
				throw new IOException("Trace backend is not supported");
			}
		}
	}
	
	public static void setTracer(io.opentracing.Tracer tracer) {
		Tracer.tracer = tracer;
	}
	
	public static io.opentracing.Tracer tracer() {
		return tracer;
	}
	
}
