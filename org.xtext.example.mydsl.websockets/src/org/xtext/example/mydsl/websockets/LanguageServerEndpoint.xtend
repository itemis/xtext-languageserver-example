package org.xtext.example.mydsl.websockets

import com.google.inject.Inject
import java.util.Collection
import org.eclipse.lsp4j.jsonrpc.Launcher
import org.eclipse.lsp4j.services.LanguageClient
import org.eclipse.lsp4j.services.LanguageClientAware
import org.eclipse.lsp4j.services.LanguageServer
import org.eclipse.lsp4j.websocket.WebSocketEndpoint

/**
 * WebSocket endpoint that connects to the Xtext language server.
 */
class LanguageServerEndpoint extends WebSocketEndpoint<LanguageClient> {
	
	@Inject LanguageServer languageServer
	
	override protected configure(Launcher.Builder<LanguageClient> builder) {
		builder.localService = languageServer
		builder.remoteInterface = LanguageClient
	}
	
	override protected connect(Collection<Object> localServices, LanguageClient remoteProxy) {
		localServices.filter(LanguageClientAware).forEach[connect(remoteProxy)]
	}
	
}