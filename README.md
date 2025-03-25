# 📊 Caso 1 – Entregable 2

**Nombre:** Carlos Abarca Mora  
**Carné:** 2024138701  
**Base de Datos:** Payment Assistant  
**Caso:** Entregable 2 del Caso 1 – Bases de Datos 1

---

# Detalles acerca de las correciones y aclaraciones
1. voice_session la IA de Amazon utiliza un sistema nube (S3 Bucket), por lo cual, los archivos no se procesan en nuestra base de datos
2. La tabla que engloba la conversación como un todo es ai_transcription, la IA utiliza una variable que es is_partial que indica
cuando una conversación está completa y lista para su analisis
3. interactionlogs es corto porque es usado junto pay_event_type, esto hace que cada log se pueda seleccionar por tipo y una descripción que permite no tener que
poner muchos datos y que sea flexible
4. Se arregló la tabla de interpretation ya que englobaba solo bancos, ahora con el uso de interpretation_types y identidades que permiten la flexibilidad, se pueden agregar información
de todo tipo.
5. ai_payment_config ahora para evitar redundancia, está enlazada paymentsmethods y funciona solo para tipos, pero la información se guarda directamente en las
tablas hechas en clase

---

## Archivos principales

| Archivo                            | Descripción                                                                 |
|------------------------------------|-----------------------------------------------------------------------------|
| [`Tablas.md`](https://github.com/CharlieAbarca/Caso-1---Entregable-2/blob/main/Tablas.md) | Contiene los resultados de las consultas en formato de tablas Markdown, organizadas por enunciado. |
| [`INSERCIONES.sql`](https://github.com/CharlieAbarca/Caso-1---Entregable-2/blob/main/INSERCIONES.sql) | Script con datos de prueba insertados en la base de datos.                 |
| [`CONSULTAS.sql`](https://github.com/CharlieAbarca/Caso-1---Entregable-2/blob/main/CONSULTAS.sql) | Consultas SQL utilizadas para responder los enunciados del entregable.     |
| [`BaseDeDatosPaymentAssistant.sql`](https://github.com/CharlieAbarca/Caso-1---Entregable-2/blob/main/BaseDeDatosPaymentAssistant.sql) | Script de creación del esquema de la base de datos.                        |
| [`PaymentAssitantPDF`]([https://github.com/CharlieAbarca/Caso-1---Entregable-2/blob/main/PaymentAssistant.pdf)) | PDF de la base de datos                     |

