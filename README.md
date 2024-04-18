Este repositorio contiene los ficheros del proyecto LibreSBC modificados para el despliegue del SBC en la red de Sarenet.

Se han realizado modificaciones respecto a los ficheros origianales y se han añadido nuevas funcionalidades como:
- Disponer de la interfaz web en el propio servidor como servicio, en vez de compilarla en local.
- No compilará Kamailio ni Freeswitch en cada despliegue con Ansible.
- Acceso al SBC sólo desde la red de Sarenet en vez de desde 0.0.0.0
- Fichero api.http para hacer peticiones a la API del SBC desde vs code.
- Implementación de NetData para visualizar y monitorear métricas en tiempo real. 

El repositorio original de LibreSBC es el siguiente: https://github.com/hnimminh/libresbc/wiki

Es importante que la primera instalación se realice mediante un *clone* del repositorio original y siguiendo la guía de instalación del mismo. 
Tras la primera instalación completa (con Kamailio y FreeSwitch), se podrán realizar los posteriores despliegues desde este repositorio.
