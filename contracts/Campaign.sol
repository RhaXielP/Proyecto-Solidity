// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Campaign — Contrato de Campana de Crowdfunding
/// @author Estudiante del Curso de Blockchain
/// @notice Campana individual con contribuir, reembolsar y reclamar.
contract Campaign {

    // ── Enums ────────────────────────────────────────────────

    /// @notice Estados posibles de la campana
    enum EstadoCampana { Activa, Exitosa, Fallida, Reclamada }

    // ── Constantes ───────────────────────────────────────────

    /// @notice Contribucion minima permitida
    uint256 public constant CONTRIBUCION_MINIMA = 0.001 ether;

    // ── Variables de Estado ──────────────────────────────────

    /// @notice Direccion del creador de la campana
    address public creador;

    /// @notice Titulo de la campana
    string public titulo;

    /// @notice Descripcion de la campana
    string public descripcion;

    /// @notice Meta de recaudacion en wei
    uint256 public metaRecaudacion;

    /// @notice Fecha limite de la campana (timestamp)
    uint256 public fechaLimite;

    /// @notice Total de ETH recaudado
    uint256 public totalRecaudado;

    /// @notice Si los fondos ya fueron reclamados por el creador
    bool public reclamado;

    /// @notice Numero de contribuyentes unicos
    uint256 public numeroContribuyentes;

    // ── Mappings ─────────────────────────────────────────────

    /// @notice Contribuciones por direccion
    mapping(address => uint256) public contribuciones;

    // ── Eventos ──────────────────────────────────────────────

    /// @notice Se emite cuando alguien contribuye a la campana
    event Contribuido(address indexed contribuyente, uint256 monto);

    /// @notice Se emite cuando un contribuyente solicita reembolso
    event Reembolsado(address indexed contribuyente, uint256 monto);

    /// @notice Se emite cuando el creador reclama los fondos
    event Reclamado(address indexed creador, uint256 monto);

    // ── Modificadores ────────────────────────────────────────

    /// @notice Requiere que la campana este activa
    modifier soloCampanaActiva() {
        require(block.timestamp < fechaLimite, "La campana ya termino");
        _;
    }

    /// @notice Restringe el acceso solo al creador de la campana
    modifier soloCreador() {
        require(msg.sender == creador, "Solo el creador puede ejecutar esta funcion");
        _;
    }

    // ── Constructor ──────────────────────────────────────────

    /// @notice Inicializa una campana de crowdfunding
    /// @param _creador Direccion del creador
    /// @param _titulo Titulo de la campana
    /// @param _descripcion Descripcion de la campana
    /// @param _metaRecaudacion Meta de recaudacion en wei
    /// @param _duracionEnDias Duracion de la campana en dias
    constructor(
        address _creador,
        string memory _titulo,
        string memory _descripcion,
        uint256 _metaRecaudacion,
        uint256 _duracionEnDias
    ) {
        require(_creador != address(0), "El creador no puede ser la direccion cero");
        require(_metaRecaudacion > 0, "La meta debe ser mayor a cero");
        require(_duracionEnDias >= 1 && _duracionEnDias <= 365, "La duracion debe ser entre 1 y 365 dias");

        creador = _creador;
        titulo = _titulo;
        descripcion = _descripcion;
        metaRecaudacion = _metaRecaudacion;
        fechaLimite = block.timestamp + (_duracionEnDias * 1 days);
    }

    // ── Funciones Principales ────────────────────────────────

    /// @notice Contribuye ETH a la campana
    function contribuir() external payable soloCampanaActiva {
        require(msg.value >= CONTRIBUCION_MINIMA, "La contribucion minima es 0.001 ETH");

        if (contribuciones[msg.sender] == 0) {
            numeroContribuyentes++;
        }

        contribuciones[msg.sender] += msg.value;
        totalRecaudado += msg.value;

        emit Contribuido(msg.sender, msg.value);
    }

    /// @notice Solicita reembolso si la campana fallo
    function reembolsar() external {
        require(block.timestamp >= fechaLimite, "La campana aun esta activa");
        require(totalRecaudado < metaRecaudacion, "La meta fue alcanzada, no puedes pedir reembolso");
        require(contribuciones[msg.sender] > 0, "No tienes contribuciones para reembolsar");

        uint256 monto = contribuciones[msg.sender];

        // CEI: Actualizar estado ANTES de enviar ETH
        contribuciones[msg.sender] = 0;

        (bool exito, ) = payable(msg.sender).call{value: monto}("");
        require(exito, "Error al enviar reembolso");

        emit Reembolsado(msg.sender, monto);
    }

    /// @notice Permite al creador reclamar los fondos si la campana fue exitosa
    function reclamar() external soloCreador {
        require(block.timestamp >= fechaLimite, "La campana aun esta activa");
        require(totalRecaudado >= metaRecaudacion, "La meta no fue alcanzada");
        require(!reclamado, "Los fondos ya fueron reclamados");

        // CEI: Actualizar estado ANTES de enviar ETH
        reclamado = true;

        (bool exito, ) = payable(creador).call{value: totalRecaudado}("");
        require(exito, "Error al enviar fondos al creador");

        emit Reclamado(creador, totalRecaudado);
    }

    // ── Funciones de Consulta ────────────────────────────────

    /// @notice Calcula el estado actual de la campana
    /// @return El estado actual de la campana
    function obtenerEstado() public view returns (EstadoCampana) {
        if (reclamado) {
            return EstadoCampana.Reclamada;
        }
        if (block.timestamp < fechaLimite) {
            return EstadoCampana.Activa;
        }
        if (totalRecaudado >= metaRecaudacion) {
            return EstadoCampana.Exitosa;
        }
        return EstadoCampana.Fallida;
    }

    /// @notice Obtiene los detalles completos de la campana
    /// @return _creador Creador de la campana
    /// @return _titulo Titulo
    /// @return _descripcion Descripcion
    /// @return _metaRecaudacion Meta de recaudacion
    /// @return _fechaLimite Fecha limite
    /// @return _totalRecaudado Total recaudado
    /// @return _reclamado Si fue reclamado
    /// @return _numeroContribuyentes Numero de contribuyentes
    /// @return _estado Estado actual
    function obtenerDetallesCampana() public view returns (
        address _creador,
        string memory _titulo,
        string memory _descripcion,
        uint256 _metaRecaudacion,
        uint256 _fechaLimite,
        uint256 _totalRecaudado,
        bool _reclamado,
        uint256 _numeroContribuyentes,
        EstadoCampana _estado
    ) {
        return (
            creador,
            titulo,
            descripcion,
            metaRecaudacion,
            fechaLimite,
            totalRecaudado,
            reclamado,
            numeroContribuyentes,
            obtenerEstado()
        );
    }
}
