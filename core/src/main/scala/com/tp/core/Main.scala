package com.tp.core

import com.typesafe.scalalogging.Logger
//import akka.actor.typed.ActorSystem
//import akka.actor.typed.ActorRef
//import akka.actor.typed.SpawnProtocol

object Main extends App {

  private[this] val logger = Logger(getClass)

//  val systemId: String = ConfigSource.default.at("akka.system.name").loadOrThrow[String]
//  implicit val system: ActorSystem[SpawnProtocol.Command] = ActorSystem(SpawnProtocol(), systemId)

  logger.info("Hello World!")


}
