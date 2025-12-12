import Foundation
import AppKit

struct ProcessInfo: Identifiable, Equatable {
    let id = UUID()
    let pid: pid_t
    let name: String
    let port: Int
    let command: String
    let processType: ProcessType
    var workingDirectory: String?
    var fullCommand: String?

    /// Short project name extracted from working directory
    var projectName: String? {
        guard let cwd = workingDirectory else { return nil }
        // Get last path component as project name
        return (cwd as NSString).lastPathComponent
    }

    static func == (lhs: ProcessInfo, rhs: ProcessInfo) -> Bool {
        lhs.pid == rhs.pid && lhs.port == rhs.port
    }
}

enum ProcessType: String, CaseIterable {
    case nodejs = "node"
    case python = "python"
    case docker = "docker"
    case postgres = "postgres"
    case redis = "redis"
    case go = "go"
    case java = "java"
    case ruby = "ruby"
    case nginx = "nginx"
    case rust = "rust"
    case php = "php"
    case unknown = "unknown"

    init(processName: String) {
        let lowercased = processName.lowercased()

        if lowercased == "node" || lowercased.contains("node") {
            self = .nodejs
        } else if lowercased.hasPrefix("python") {
            self = .python
        } else if lowercased == "docker" || lowercased.hasPrefix("com.docker") {
            self = .docker
        } else if lowercased == "postgres" || lowercased.hasPrefix("postgres") {
            self = .postgres
        } else if lowercased.contains("redis") {
            self = .redis
        } else if lowercased == "go" {
            self = .go
        } else if lowercased == "java" || lowercased.contains("java") {
            self = .java
        } else if lowercased == "ruby" || lowercased.hasPrefix("ruby") {
            self = .ruby
        } else if lowercased == "nginx" {
            self = .nginx
        } else if lowercased.contains("cargo") || lowercased.contains("rustc") {
            self = .rust
        } else if lowercased == "php" || lowercased.hasPrefix("php") {
            self = .php
        } else {
            self = .unknown
        }
    }

    /// Icon name in Assets.xcassets or SF Symbol fallback
    var iconName: String {
        switch self {
        case .nodejs: return "icon-nodejs"
        case .python: return "icon-python"
        case .docker: return "icon-docker"
        case .postgres: return "icon-postgres"
        case .redis: return "icon-redis"
        case .go: return "icon-go"
        case .java: return "icon-java"
        case .ruby: return "icon-ruby"
        case .nginx: return "icon-nginx"
        case .rust: return "icon-rust"
        case .php: return "icon-php"
        case .unknown: return "gearshape"
        }
    }

    /// Display name for UI
    var displayName: String {
        switch self {
        case .nodejs: return "Node.js"
        case .python: return "Python"
        case .docker: return "Docker"
        case .postgres: return "PostgreSQL"
        case .redis: return "Redis"
        case .go: return "Go"
        case .java: return "Java"
        case .ruby: return "Ruby"
        case .nginx: return "Nginx"
        case .rust: return "Rust"
        case .php: return "PHP"
        case .unknown: return "Process"
        }
    }
}
