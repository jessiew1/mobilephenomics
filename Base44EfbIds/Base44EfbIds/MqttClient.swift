import Foundation
import os.log

public struct MqttConfig: Equatable {
    public let host: String
    public let port: UInt16
    public let clientId: String
    public let username: String?
    public let password: String?
    public let tls: Bool
    public let topicBase: String

    public init(host: String, port: UInt16, clientId: String, username: String? = nil, password: String? = nil, tls: Bool = true, topicBase: String) {
        self.host = host
        self.port = port
        self.clientId = clientId
        self.username = username
        self.password = password
        self.tls = tls
        self.topicBase = topicBase
    }
}

public protocol MQTTClientType {
    var isConnected: Bool { get }
    func connect()
    func disconnect()
    func publish(topic: String, message: String)
}

public final class MqttClient: MQTTClientType {
    private let config: MqttConfig
    private let logger = Logger(subsystem: "Base44EfbIds", category: "MQTT")
    public private(set) var isConnected: Bool = false

    #if canImport(CocoaMQTT)
    private var client: CocoaMQTT?
    #endif

    public init(config: MqttConfig) {
        self.config = config
        setupClient()
    }

    private func setupClient() {
        #if canImport(CocoaMQTT)
        let clientID = config.clientId
        let mqtt = CocoaMQTT(clientID: clientID, host: config.host, port: UInt16(config.port))
        mqtt.username = config.username
        mqtt.password = config.password
        mqtt.enableSSL = config.tls
        mqtt.autoReconnect = true
        mqtt.keepAlive = 30
        mqtt.delegate = self
        client = mqtt
        #endif
    }

    public func connect() {
        #if canImport(CocoaMQTT)
        client?.connect()
        #else
        isConnected = true
        logger.debug("MQTT client connected (stub)")
        #endif
    }

    public func disconnect() {
        #if canImport(CocoaMQTT)
        client?.disconnect()
        #endif
        isConnected = false
    }

    public func publish(topic: String, message: String) {
        #if canImport(CocoaMQTT)
        client?.publish(CocoaMQTTMessage(topic: topic, string: message))
        #else
        logger.log("Publishing to \(topic): \(message)")
        #endif
    }
}

#if canImport(CocoaMQTT)
extension MqttClient: CocoaMQTTDelegate {
    public func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        isConnected = true
        logger.log("Connected to MQTT with ack: \(ack)")
    }

    public func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        isConnected = false
        if let err { logger.error("Disconnected: \(err.localizedDescription)") }
    }
}
#endif
