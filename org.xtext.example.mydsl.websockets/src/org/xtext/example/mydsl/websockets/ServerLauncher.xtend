package org.xtext.example.mydsl.websockets

import com.google.inject.Guice
import com.google.inject.Injector
import java.net.InetSocketAddress
import javax.websocket.Endpoint
import javax.websocket.server.ServerEndpointConfig
import org.eclipse.jetty.server.Server
import org.eclipse.jetty.util.log.Slf4jLog
import org.eclipse.jetty.webapp.WebAppContext
import org.eclipse.jetty.websocket.jsr356.server.deploy.WebSocketServerContainerInitializer
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.ide.server.ServerModule

/**
 * Main class for launching the ELK Graph server.
 */
@FinalFieldsConstructor
class ServerLauncher {
	
	def static void main(String[] args) {
		
		val rootPath = if (args.length >= 1) args.get(0) else '../..'
		val launcher = new ServerLauncher(rootPath)
		launcher.start()
	}

	val String rootPath
	
	
	def void start() {
		val log = new Slf4jLog(ServerLauncher.name)
		
		// Set up Jetty server
		val server = new Server(new InetSocketAddress(8080))
		val webAppContext = new WebAppContext => [
			//  https://github.com/TypeFox/monaco-languageclient/blob/master/example/src/client.ts
			resourceBase = "/data/git/monaco-languageclient/example/lib"
			log.info('Serving client app from ' + resourceBase)
			welcomeFiles = #['index.html']
			setInitParameter('org.eclipse.jetty.servlet.Default.dirAllowed', 'false')
			setInitParameter('org.eclipse.jetty.servlet.Default.useFileMappedBuffer', 'false')
		]
		server.handler = webAppContext
		
		// Configure web socket
		val container = WebSocketServerContainerInitializer.configureContext(webAppContext)
		val endpointConfigBuilder = ServerEndpointConfig.Builder.create(LanguageServerEndpoint, '/demo')
		val injector = Guice.createInjector(new ServerModule() {
			
			override protected configure() {
				super.configure()
				bind(Endpoint).to(LanguageServerEndpoint)
			}
			
		})
		endpointConfigBuilder.configurator(new ServerEndpointConfig.Configurator {
			override <T> getEndpointInstance(Class<T> endpointClass) throws InstantiationException {
				val i = injector.getInstance(Endpoint) as T
				println(i)
				return i
			}
		})
		container.addEndpoint(endpointConfigBuilder.build())
		
		// Start the server
		try {
			server.start()
			log.info('Press enter to stop the server...')
			new Thread[
		    	val key = System.in.read()
		    	server.stop()
		    	if (key == -1)
		    		log.warn('The standard input stream is empty')
		    ].start()
			server.join()
		} catch (Exception exception) {
			log.warn('Shutting down due to exception', exception)
			System.exit(1)
		}
	}
	
}