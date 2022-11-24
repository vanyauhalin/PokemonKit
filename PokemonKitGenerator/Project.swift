import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: .name(by: "Generator"),
  organizationName: .organizationName(),
  targets: [
    Target(
      name: .name(by: "Generator"),
      platform: .macOS,
      product: .commandLineTool,
      bundleId: .bundleId(by: "Generator"),
      deploymentTarget: .macOS(targetVersion: "13.0"),
      sources: .configure(),
      scripts: [
        .lintProject(by: "Generator")
      ]
    )
  ]
)
