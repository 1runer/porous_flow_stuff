[Mesh]
  construct_side_list_from_node_list = true
  [matrix_fracture]
    type = FileMeshGenerator
    file = cube_16m_fracture_half_c4.msh
  []
  [injection_node_set]
    type = ExtraNodesetGenerator
    input = matrix_fracture
    coord = '0 0 0'
    new_boundary = 'injection_node_set'
  []
  [fracture]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'fracture'
    new_block_name = 'fracture'
    input = injection_node_set
  []
  [deleteBlock]
    type = BlockDeletionGenerator
    block = 'left right'
    input = fracture
    delete_exteriors = false
  []
  use_displaced_mesh = false
[]

[GlobalParams]
  PorousFlowDictator = dictator
  multiply_by_density = true
  gravity = '0 0 0'
[]

[Variables]
  [pressure]
    initial_condition = 1e7
  []
  [tracer]
    initial_condition = 0
  []
[]

[AuxVariables]
  [velocity_x]
    family = MONOMIAL
    order = CONSTANT
  []
  [velocity_y]
    family = MONOMIAL
    order = CONSTANT
  []
  [velocity_z]
    family = MONOMIAL
    order = CONSTANT
  []
  [grad_p_x]
    family = MONOMIAL
    order = CONSTANT
  []
  [grad_p_y]
    family = MONOMIAL
    order = CONSTANT
  []
  [grad_p_z]
    family = MONOMIAL
    order = CONSTANT
  []
  [density]
    family = MONOMIAL
    order = CONSTANT
  []
  [viscosity]
    family = MONOMIAL
    order = CONSTANT
  []
  [perm_x]
    family = MONOMIAL
    order = CONSTANT
  []
  [perm_y]
    family = MONOMIAL
    order = CONSTANT
  []
  [perm_z]
    family = MONOMIAL
    order = CONSTANT
  []
  [porosity]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
  # Kernel result has to be divided by aperture to give true result
  [velocity_x]
    type = PorousFlowDarcyVelocityComponent
    variable = velocity_x
    component = x
  []
  [velocity_y]
    type = PorousFlowDarcyVelocityComponent
    variable = velocity_y
    component = y
  []
  [velocity_z]
    type = PorousFlowDarcyVelocityComponent
    variable = velocity_z
    component = z
  []
  # Auxkernels don't work for 2D in 2D, but should.
  # [velocity_xf]
  #   type = PorousFlowDarcyVelocityComponentLowerDimensional
  #   variable = velocity_x
  #   component = x
  #   block = 'fracture'
  #   aperture = '1e-4'
  # []
  # [velocity_yf]
  #   type = PorousFlowDarcyVelocityComponentLowerDimensional
  #   variable = velocity_y
  #   component = y
  #   block = 'fracture'
  #   aperture = '1e-4'
  # []
  # [velocity_zf]
  #   type = PorousFlowDarcyVelocityComponentLowerDimensional
  #   variable = velocity_z
  #   component = z
  #   block = 'fracture'
  #   aperture = '1e-4'
  # []
  [density]
    type = PorousFlowPropertyAux
    variable = density
    property = density
  []
  [viscosity]
    type = PorousFlowPropertyAux
    variable = viscosity
    property = viscosity
  []
  [porosity]
    type = PorousFlowPropertyAux
    variable = porosity
    property = porosity
  []
  [perm_x]
    type = PorousFlowPropertyAux
    variable = perm_x
    property = permeability
    row = 0
    column = 0
  []
  [perm_y]
    type = PorousFlowPropertyAux
    variable = perm_y
    property = permeability
    row = 1
    column = 1
  []
  [perm_z]
    type = PorousFlowPropertyAux
    variable = perm_z
    property = permeability
    row = 2
    column = 2
  []
  [grad_p_x]
    type = MaterialStdVectorRealGradientAux
    variable = grad_p_x
    component = 0
    property = PorousFlow_grad_porepressure_qp
  []
  [grad_p_y]
    type = MaterialStdVectorRealGradientAux
    variable = grad_p_y
    component = 1
    property = PorousFlow_grad_porepressure_qp
  []
  [grad_p_z]
    type = MaterialStdVectorRealGradientAux
    variable = grad_p_z
    component = 2
    property = PorousFlow_grad_porepressure_qp
  []
[]

[BCs]
  [p_right]
    type = DirichletBC
    boundary = '7'
    value = 1e7
    variable = pressure
  []
  [tracer_in]
    type = DirichletBC
    boundary = 'injection_node_set'
    value = 0.1
    variable = tracer
  []
  [tracer_right]
    type = DirichletBC
    boundary = '7'
    value = 0
    variable = tracer
  []
[]

[DiracKernels]
  [inj]
    type = PorousFlowSquarePulsePointSource
    start_time = 0
    point = '0 0 0'
    mass_flux = 1 # kg/s
    variable = pressure
    point_not_found_behavior = WARNING
  []
[]

[Kernels]
  [mass1]
    type = PorousFlowMassTimeDerivative
    fluid_component = 1
    variable = pressure
  []
  [adv1]
    type = PorousFlowFullySaturatedAdvectiveFlux
    fluid_component = 1
    variable = pressure
  []
  [adv0]
    type = PorousFlowFullySaturatedAdvectiveFlux
    fluid_component = 0
    variable = tracer
  []
  [mass0]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = tracer
  []
  [disp0]
    type = PorousFlowDispersiveFlux
    fluid_component = 0
    variable = tracer
    disp_trans = 0
    disp_long = 0
  []
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'pressure tracer'
    number_fluid_phases = 1
    number_fluid_components = 2
  []
[]

[FluidProperties]
  [fluid]
    type = SimpleFluidProperties
    bulk_modulus = 2e+9
    density0 = 1000
    thermal_expansion = 0
    viscosity = 1e-4
  []
[]

[Materials]
  [temperature]
    type = PorousFlowTemperature
  []
  [ppss]
    type = PorousFlow1PhaseFullySaturated
    porepressure = pressure
  []
  [massfrac]
    type = PorousFlowMassFraction
    mass_fraction_vars = 'tracer'
    PorousFlowDictator = dictator
  []
  [single_fluid]
    type = PorousFlowSingleComponentFluid
    fp = fluid
    phase = 0
  []
  [poro_fracture]
    type = PorousFlowPorosityConst
    porosity = '1e-4' # a = 1e-4
    block = 'fracture'
  []
  # [poro_matrix]
  #   type = PorousFlowPorosityConst
  #   porosity = '1e-1'
  #   block = 'left right'
  # []
  [diff1_all]
    type = PorousFlowDiffusivityConst
    diffusion_coeff = '0 0'
    tortuosity = 1
  []
  # [permeability_matrix]
  #   type = PorousFlowPermeabilityConst
  #   permeability = '1E-20 0 0 0 1E-20 0 0 0 1E-20'
  #   block = 'left right'
  # []
  [permeability_fracture]
    type = PorousFlowPermeabilityConstFromVar
    perm_xx = 8.333333e-14 # a=1e-4
    perm_yy = 8.333333e-14 # a=1e-4
    perm_zz = 8.333333e-14 # a=1e-4
    block = 'fracture'
  []
  [relp]
    type = PorousFlowRelativePermeabilityConst
    phase = 0
    kr = 1
  []
  [darcy_velocity_qp]
    type = PorousFlowDarcyVelocityMaterial
  []
[]

[Preconditioning]
  active = 'mumps'
  [mumps]
    type = SMP
    full = true
    petsc_options = '-ksp_diagonal_scale -ksp_diagonal_scale_fix -ksp_gmres_modifiedgramschmidt'
    petsc_options_iname = '-ksp_type -pc_type -pc_factor_mat_solver_package -pc_factor_shift_type -snes_rtol -snes_atol -snes_max_it -ksp_atol -ksp_rtol'
    petsc_options_value = 'gmres      lu       mumps                         NONZERO               1E-10       1E-10       100         1E-10     1E-18'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  end_time = 10
  dt = 0.5
[]

[Outputs]
  print_linear_residuals = true
  print_nonlinear_residuals = true
  perf_graph = true
  checkpoint = true
  exodus = true
  [debug]
    type = VariableResidualNormsDebugOutput
  []
[]
