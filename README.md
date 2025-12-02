Español:
Simulador de Parking – Processing + Arduino
Descripción del Proyecto

Este proyecto implementa un sistema de simulación de estacionamiento desarrollado en Processing e integrado con hardware mediante Arduino. Su objetivo es modelar el funcionamiento de un estacionamiento real, permitiendo gestionar el ingreso y salida de vehículos, la administración de socios, el control de una barrera física, la generación de estadísticas y la persistencia de datos mediante archivos y backups automáticos.

El sistema está concebido para ofrecer un entorno automatizado, seguro y extensible. Incluye mecanismos de funcionamiento manual que permiten mantener la operación aun cuando la aplicación principal no esté disponible, garantizando independencia y continuidad.

Funcionalidades Principales
1. Gestión de Ingreso y Salida
 Registro en tiempo real del acceso y egreso de vehículos.
 Validación diferenciada entre usuarios socios y no socios.

2. Sistema de Socios
Creación, modificación y persistencia de socios.
Generación de códigos de acceso individuales.
Control de identidad.

3. Modo Manual de Acceso
Activación desde la interfaz principal.
Permite a los socios ingresar manualmente su código en el dispositivo físico.
Funciona incluso sin la interfaz gráfica activa, proporcionando independencia del sistema principal.

4. Control de Barrera mediante Arduino
Apertura y cierre automático según validación de acceso.
Comunicación en tiempo real con Processing.
Visualización clara de información relevante para el usuario.

5. Sistema de Backup y Recuperación
Guardado de datos en archivos para asegurar persistencia.
Copias automáticas para prevenir pérdidas ante caídas o fallos.
Recuperación del estado del sistema en ejecuciones posteriores.

6. Manejo de Archivos
Registro de actividad de vehículos, socios y eventos relevantes.
Archivos estructurados diseñados para auditoría futura.
Exportación y revisión de información histórica.

7. Estadísticas
Generación automática de estadísticas de uso con diferentes alcances temporales.
Reportes diarios, semanales, mensuales o históricos.
Indicadores de ocupación, cantidad de ingresos, actividad de socios.

Interfaz y Experiencia de Usuario
El sistema muestra en pantalla información esencial del estacionamiento, incluyendo ocupación, identificación de socios, validaciones de acceso y estados operativos.
La comunicación con Arduino permite presentar información resumida a los usuarios que se encuentran físicamente en el acceso del estacionamiento.
El diseño de la interfaz busca ser claro y eficiente, permitiendo operar el sistema de forma rápida y con bajo margen de error. La experiencia está enfocada en la usabilidad y en la representación visual comprensible del estado general del estacionamiento.

Objetivos del Proyecto
Simular el funcionamiento de un estacionamiento real, integrando software y hardware.
Administrar usuarios y accesos con persistencia y trazabilidad.
Garantizar seguridad de datos mediante backups y recuperación automática.
Generar estadísticas para análisis operativo.
Proveer un sistema versátil que funcione tanto de forma automática como manual.

Resultados e Impacto
El proyecto demuestra la viabilidad de un sistema de estacionamiento automatizado con:
Gestión eficiente de usuarios y accesos.
Interacción fluida entre software y dispositivos físicos.
Mecanismos de seguridad frente a fallos.
Registro y análisis de datos históricos.
Autonomía operativa mediante modos alternativos de ingreso.

El diseño modular permite ampliar el sistema con nuevas tecnologías como RFID, sensores, cámaras o módulos de pago, lo que lo convierte en un punto de partida sólido para desarrollos reales o académicos.

Conclusión

El proyecto ofrece una simulación completa y funcional de un estacionamiento inteligente, integrando control físico, automatización y análisis de datos.
El uso combinado de Processing y Arduino permite calibrar tanto la interacción hombre-máquina como la lógica de gestión operativa.
Su diseño, centrado en la persistencia, la seguridad y la extensibilidad, lo posiciona como una solución adaptable para investigación, educación y potencial desarrollo comercial.


English:
Parking Simulator – Processing + Arduino
Project Description

This project implements a parking simulation system developed in Processing and integrated with hardware through Arduino. Its goal is to model the operation of a real parking facility, enabling the management of vehicle entry and exit, member administration, physical barrier control, statistics generation, and data persistence through files and automatic backups.

The system is designed to provide an automated, secure, and extensible environment. It includes manual operation mechanisms that allow continued functionality even when the main application is not available, ensuring independence and continuity.

Main Features

Entry and Exit Management

Real-time logging of vehicle access and departures.

Differentiated validation for member and non-member users.

Member System

Creation, modification, and persistence of members.

Generation of individual access codes.

Identity control.

Manual Access Mode

Activated from the main interface.

Allows members to manually enter their code on the physical device.

Operates even without the graphical interface, ensuring independence from the main system.

Barrier Control via Arduino

Automatic opening and closing based on access validation.

Real-time communication with Processing.

Clear visualization of relevant information for the user.

Backup and Recovery System

Data storage in files to ensure persistence.

Automatic backups to prevent loss due to crashes or failures.

System state recovery during subsequent executions.

File Management

Logging of vehicle activity, members, and relevant events.

Structured files designed for future auditing.

Export and review of historical information.

Statistics

Automatic generation of usage statistics with different time scopes.

Daily, weekly, monthly, or historical reports.

Indicators of occupancy, number of entries, and member activity.

Interface and User Experience

The system displays essential parking information on screen, including occupancy, member identification, access validation, and operational states.
Communication with Arduino enables summarized information to be presented to users physically located at the parking entrance.
The interface is designed to be clear and efficient, allowing quick operation with a low margin of error. The experience focuses on usability and visually understandable representation of the overall parking status.

Project Objectives

Simulate the operation of a real parking facility, integrating software and hardware.

Manage users and access with persistence and traceability.

Ensure data security through backups and automatic recovery.

Generate statistics for operational analysis.

Provide a versatile system that operates both automatically and manually.

Results and Impact

The project demonstrates the feasibility of an automated parking system with:

Efficient user and access management.

Smooth interaction between software and physical devices.

Security mechanisms against failures.

Logging and analysis of historical data.

Operational autonomy through alternative access modes.

The modular design allows the system to be expanded with new technologies such as RFID, sensors, cameras, or payment modules, making it a solid starting point for real-world or academic developments.

Conclusion

The project delivers a complete and functional simulation of an intelligent parking system, integrating physical control, automation, and data analysis.
The combined use of Processing and Arduino enables fine-tuning of both human-machine interaction and operational management logic.
Its design, focused on persistence, security, and extensibility, positions it as an adaptable solution for research, education, and potential commercial development.
