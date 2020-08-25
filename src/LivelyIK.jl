module LivelyIK

using PyCall
collision_transfer = pyimport("lively_ik.utils.collision_transfer")
lively_ik = pyimport("lively_ik")

include("groove/groove.jl")
include("spacetime/spacetime.jl")
include("utils/utils.jl")
include("relaxed_ik/relaxed_ik.jl")

struct Goals
    positions::Array{Array{Float64,3}}
    quats    ::Array{Array{Float64,4}}
    dc       ::Array{Float64}
    time     ::Float64
    bias     ::Array{Float64,3}
    weights  ::Array{Float64}
end

function Goals(goal_msg)
    positions = []
    quats = []

    # Create POS/QUAT Goals from EE Poses
    for i = 1:length(goal_msg.ee_poses)
        p = goal_msg.ee_poses[i]

        pos_x = p.position.x
        pos_y = p.position.y
        pos_z = p.position.z

        quat_w = p.orientation.w
        quat_x = p.orientation.x
        quat_y = p.orientation.y
        quat_z = p.orientation.z

        push!(positions, [pos_x, pos_y, pos_z])
        push!(quats, Quat(quat_w, quat_x, quat_y, quat_z))
    end

    # Create DC Goals from DC Values
    dc = goal_msg.dc_values

    # Get Time from Header
    time = rclpy_time.Time.from_msg(goal_msg.header.stamp).nanoseconds * 10^-9

    # Extract Bias
    bias = [goal_msg.bias.x,goal_msg.bias.y,goal_msg.bias.z]

    # Extract Weights
    weights = goal_msg.objective_weights

    return Goals(positions, quats, dc, time, bias, weights)
end

function Goals(lively_ik,info_data)
    num_chains = lively_ik.relaxedIK_vars.robot.num_chains

    positions = []
    quats = []

    # Create POS/QUAT Goals from EE Poses
    for i = 1:length(num_chains)
        push!(positions, [0.0, 0.0, 0.0])
        push!(quats, Quat(1.0, 0.0, 0.0, 0.0))
    end

    # Create DC Goals from DC Values
    dc = info_data["starting_config"]

    # Get Time from Header
    time = 0.0

    # Extract Bias
    bias = [1.0,1.0,1.0]

    # Extract Weights
    weights = lively_ik.relaxedIK_vars.vars.weight_priors

    println(positions, quats, dc, time, bias, weights)
    convert(Array{Array{Float64,3}},positions)
    convert(Array{Array{Float64,4}},quats)
    convert(Array{Float64},dc)
    convert(Float64,time)
    convert(Array{Float64,3},bias)
    convert(Array{Float64},weights)

    return Goals(positions, quats, dc, time, bias, weights)
end



export RelaxedIK, get_standard, solve, Goals

end # module
