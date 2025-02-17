��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq cmodels.shapes_cnn
ShapesCNN
qX?   /home/lgpu0444/diagnostics-shapes/baseline/models/shapes_cnn.pyqX{  class ShapesCNN(nn.Module):
    def __init__(self, n_out_features):
        super().__init__()

        n_filters = 20

        self.conv_net = nn.Sequential(
            nn.Conv2d(3, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU(),
            nn.Conv2d(n_filters, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU(),
            nn.Conv2d(n_filters, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU()
        )
        self.lin = nn.Sequential(nn.Linear(80, n_out_features), nn.ReLU())

        self._init_params()

    def _init_params(self):
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                nn.init.kaiming_normal_(m.weight, mode="fan_out", nonlinearity="relu")
            elif isinstance(m, nn.BatchNorm2d):
                nn.init.constant_(m.weight, 1)
                nn.init.constant_(m.bias, 0)

    def forward(self, x):
        batch_size = x.size(0)
        output = self.conv_net(x)
        output = output.view(batch_size, -1)
        output = self.lin(output)
        return output
qtqQ)�q}q(X   _backendqctorch.nn.backends.thnn
_get_thnn_function_backend
q)Rq	X   _parametersq
ccollections
OrderedDict
q)RqX   _buffersqh)RqX   _backward_hooksqh)RqX   _forward_hooksqh)RqX   _forward_pre_hooksqh)RqX   _state_dict_hooksqh)RqX   _load_state_dict_pre_hooksqh)RqX   _modulesqh)Rq(X   conv_netq(h ctorch.nn.modules.container
Sequential
qXO   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/container.pyqX�	  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    def __len__(self):
        return len(self._modules)

    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    def forward(self, input):
        for module in self._modules.values():
            input = module(input)
        return input
qtqQ)�q }q!(hh	h
h)Rq"hh)Rq#hh)Rq$hh)Rq%hh)Rq&hh)Rq'hh)Rq(hh)Rq)(X   0q*(h ctorch.nn.modules.conv
Conv2d
q+XJ   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/conv.pyq,X!  class Conv2d(_ConvNd):
    r"""Applies a 2D convolution over an input signal composed of several input
    planes.

    In the simplest case, the output value of the layer with input size
    :math:`(N, C_{\text{in}}, H, W)` and output :math:`(N, C_{\text{out}}, H_{\text{out}}, W_{\text{out}})`
    can be precisely described as:

    .. math::
        \text{out}(N_i, C_{\text{out}_j}) = \text{bias}(C_{\text{out}_j}) +
        \sum_{k = 0}^{C_{\text{in}} - 1} \text{weight}(C_{\text{out}_j}, k) \star \text{input}(N_i, k)


    where :math:`\star` is the valid 2D `cross-correlation`_ operator,
    :math:`N` is a batch size, :math:`C` denotes a number of channels,
    :math:`H` is a height of input planes in pixels, and :math:`W` is
    width in pixels.

    * :attr:`stride` controls the stride for the cross-correlation, a single
      number or a tuple.

    * :attr:`padding` controls the amount of implicit zero-paddings on both
      sides for :attr:`padding` number of points for each dimension.

    * :attr:`dilation` controls the spacing between the kernel points; also
      known as the à trous algorithm. It is harder to describe, but this `link`_
      has a nice visualization of what :attr:`dilation` does.

    * :attr:`groups` controls the connections between inputs and outputs.
      :attr:`in_channels` and :attr:`out_channels` must both be divisible by
      :attr:`groups`. For example,

        * At groups=1, all inputs are convolved to all outputs.
        * At groups=2, the operation becomes equivalent to having two conv
          layers side by side, each seeing half the input channels,
          and producing half the output channels, and both subsequently
          concatenated.
        * At groups= :attr:`in_channels`, each input channel is convolved with
          its own set of filters, of size:
          :math:`\left\lfloor\frac{C_\text{out}}{C_\text{in}}\right\rfloor`.

    The parameters :attr:`kernel_size`, :attr:`stride`, :attr:`padding`, :attr:`dilation` can either be:

        - a single ``int`` -- in which case the same value is used for the height and width dimension
        - a ``tuple`` of two ints -- in which case, the first `int` is used for the height dimension,
          and the second `int` for the width dimension

    .. note::

         Depending of the size of your kernel, several (of the last)
         columns of the input might be lost, because it is a valid `cross-correlation`_,
         and not a full `cross-correlation`_.
         It is up to the user to add proper padding.

    .. note::

        When `groups == in_channels` and `out_channels == K * in_channels`,
        where `K` is a positive integer, this operation is also termed in
        literature as depthwise convolution.

        In other words, for an input of size :math:`(N, C_{in}, H_{in}, W_{in})`,
        a depthwise convolution with a depthwise multiplier `K`, can be constructed by arguments
        :math:`(in\_channels=C_{in}, out\_channels=C_{in} \times K, ..., groups=C_{in})`.

    .. include:: cudnn_deterministic.rst

    Args:
        in_channels (int): Number of channels in the input image
        out_channels (int): Number of channels produced by the convolution
        kernel_size (int or tuple): Size of the convolving kernel
        stride (int or tuple, optional): Stride of the convolution. Default: 1
        padding (int or tuple, optional): Zero-padding added to both sides of the input. Default: 0
        dilation (int or tuple, optional): Spacing between kernel elements. Default: 1
        groups (int, optional): Number of blocked connections from input channels to output channels. Default: 1
        bias (bool, optional): If ``True``, adds a learnable bias to the output. Default: ``True``

    Shape:
        - Input: :math:`(N, C_{in}, H_{in}, W_{in})`
        - Output: :math:`(N, C_{out}, H_{out}, W_{out})` where

          .. math::
              H_{out} = \left\lfloor\frac{H_{in}  + 2 \times \text{padding}[0] - \text{dilation}[0]
                        \times (\text{kernel\_size}[0] - 1) - 1}{\text{stride}[0]} + 1\right\rfloor

          .. math::
              W_{out} = \left\lfloor\frac{W_{in}  + 2 \times \text{padding}[1] - \text{dilation}[1]
                        \times (\text{kernel\_size}[1] - 1) - 1}{\text{stride}[1]} + 1\right\rfloor

    Attributes:
        weight (Tensor): the learnable weights of the module of shape
                         (out_channels, in_channels, kernel_size[0], kernel_size[1]).
                         The values of these weights are sampled from
                         :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                         :math:`k = \frac{1}{C_\text{in} * \prod_{i=0}^{1}\text{kernel\_size}[i]}`
        bias (Tensor):   the learnable bias of the module of shape (out_channels). If :attr:`bias` is ``True``,
                         then the values of these weights are
                         sampled from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                         :math:`k = \frac{1}{C_\text{in} * \prod_{i=0}^{1}\text{kernel\_size}[i]}`

    Examples::

        >>> # With square kernels and equal stride
        >>> m = nn.Conv2d(16, 33, 3, stride=2)
        >>> # non-square kernels and unequal stride and with padding
        >>> m = nn.Conv2d(16, 33, (3, 5), stride=(2, 1), padding=(4, 2))
        >>> # non-square kernels and unequal stride and with padding and dilation
        >>> m = nn.Conv2d(16, 33, (3, 5), stride=(2, 1), padding=(4, 2), dilation=(3, 1))
        >>> input = torch.randn(20, 16, 50, 100)
        >>> output = m(input)

    .. _cross-correlation:
        https://en.wikipedia.org/wiki/Cross-correlation

    .. _link:
        https://github.com/vdumoulin/conv_arithmetic/blob/master/README.md
    """
    def __init__(self, in_channels, out_channels, kernel_size, stride=1,
                 padding=0, dilation=1, groups=1, bias=True):
        kernel_size = _pair(kernel_size)
        stride = _pair(stride)
        padding = _pair(padding)
        dilation = _pair(dilation)
        super(Conv2d, self).__init__(
            in_channels, out_channels, kernel_size, stride, padding, dilation,
            False, _pair(0), groups, bias)

    @weak_script_method
    def forward(self, input):
        return F.conv2d(input, self.weight, self.bias, self.stride,
                        self.padding, self.dilation, self.groups)
q-tq.Q)�q/}q0(hh	h
h)Rq1(X   weightq2ctorch._utils
_rebuild_parameter
q3ctorch._utils
_rebuild_tensor_v2
q4((X   storageq5ctorch
FloatStorage
q6X   35492848q7X   cuda:0q8MNtq9QK (KKKKtq:(KK	KKtq;�h)Rq<tq=Rq>�h)Rq?�q@RqAX   biasqBh3h4((h5h6X   36281040qCX   cuda:0qDKNtqEQK K�qFK�qG�h)RqHtqIRqJ�h)RqK�qLRqMuhh)RqNhh)RqOhh)RqPhh)RqQhh)RqRhh)RqShh)RqTX   trainingqU�X   in_channelsqVKX   out_channelsqWKX   kernel_sizeqXKK�qYX   strideqZKK�q[X   paddingq\K K �q]X   dilationq^KK�q_X
   transposedq`�X   output_paddingqaK K �qbX   groupsqcKubX   1qd(h ctorch.nn.modules.batchnorm
BatchNorm2d
qeXO   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/batchnorm.pyqfX#  class BatchNorm2d(_BatchNorm):
    r"""Applies Batch Normalization over a 4D input (a mini-batch of 2D inputs
    with additional channel dimension) as described in the paper
    `Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift`_ .

    .. math::

        y = \frac{x - \mathrm{E}[x]}{ \sqrt{\mathrm{Var}[x] + \epsilon}} * \gamma + \beta

    The mean and standard-deviation are calculated per-dimension over
    the mini-batches and :math:`\gamma` and :math:`\beta` are learnable parameter vectors
    of size `C` (where `C` is the input size). By default, the elements of :math:`\gamma` are sampled
    from :math:`\mathcal{U}(0, 1)` and the elements of :math:`\beta` are set to 0.

    Also by default, during training this layer keeps running estimates of its
    computed mean and variance, which are then used for normalization during
    evaluation. The running estimates are kept with a default :attr:`momentum`
    of 0.1.

    If :attr:`track_running_stats` is set to ``False``, this layer then does not
    keep running estimates, and batch statistics are instead used during
    evaluation time as well.

    .. note::
        This :attr:`momentum` argument is different from one used in optimizer
        classes and the conventional notion of momentum. Mathematically, the
        update rule for running statistics here is
        :math:`\hat{x}_\text{new} = (1 - \text{momentum}) \times \hat{x} + \text{momemtum} \times x_t`,
        where :math:`\hat{x}` is the estimated statistic and :math:`x_t` is the
        new observed value.

    Because the Batch Normalization is done over the `C` dimension, computing statistics
    on `(N, H, W)` slices, it's common terminology to call this Spatial Batch Normalization.

    Args:
        num_features: :math:`C` from an expected input of size
            :math:`(N, C, H, W)`
        eps: a value added to the denominator for numerical stability.
            Default: 1e-5
        momentum: the value used for the running_mean and running_var
            computation. Can be set to ``None`` for cumulative moving average
            (i.e. simple average). Default: 0.1
        affine: a boolean value that when set to ``True``, this module has
            learnable affine parameters. Default: ``True``
        track_running_stats: a boolean value that when set to ``True``, this
            module tracks the running mean and variance, and when set to ``False``,
            this module does not track such statistics and always uses batch
            statistics in both training and eval modes. Default: ``True``

    Shape:
        - Input: :math:`(N, C, H, W)`
        - Output: :math:`(N, C, H, W)` (same shape as input)

    Examples::

        >>> # With Learnable Parameters
        >>> m = nn.BatchNorm2d(100)
        >>> # Without Learnable Parameters
        >>> m = nn.BatchNorm2d(100, affine=False)
        >>> input = torch.randn(20, 100, 35, 45)
        >>> output = m(input)

    .. _`Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift`:
        https://arxiv.org/abs/1502.03167
    """

    @weak_script_method
    def _check_input_dim(self, input):
        if input.dim() != 4:
            raise ValueError('expected 4D input (got {}D input)'
                             .format(input.dim()))
qgtqhQ)�qi}qj(hh	h
h)Rqk(h2h3h4((h5h6X   35928976qlX   cuda:0qmKNtqnQK K�qoK�qp�h)RqqtqrRqs�h)Rqt�quRqvhBh3h4((h5h6X   36360656qwX   cuda:0qxKNtqyQK K�qzK�q{�h)Rq|tq}Rq~�h)Rq�q�Rq�uhh)Rq�(X   running_meanq�h4((h5h6X   35909536q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rq�tq�Rq�X   running_varq�h4((h5h6X   34076704q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rq�tq�Rq�X   num_batches_trackedq�h4((h5ctorch
LongStorage
q�X   35553728q�X   cuda:0q�KNtq�QK ))�h)Rq�tq�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�X   num_featuresq�KX   epsq�G>�����h�X   momentumq�G?�������X   affineq��X   track_running_statsq��ubX   2q�(h ctorch.nn.modules.activation
ReLU
q�XP   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/activation.pyq�X�  class ReLU(Threshold):
    r"""Applies the rectified linear unit function element-wise
    :math:`\text{ReLU}(x)= \max(0, x)`

    .. image:: scripts/activation_images/ReLU.png

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)
    """

    def __init__(self, inplace=False):
        super(ReLU, self).__init__(0., 0., inplace)

    def extra_repr(self):
        inplace_str = 'inplace' if self.inplace else ''
        return inplace_str
q�tq�Q)�q�}q�(hh	h
h)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�X	   thresholdq�G        X   valueq�G        X   inplaceq��ubX   3q�h+)�q�}q�(hh	h
h)Rq�(h2h3h4((h5h6X   36243872q�X   cuda:0q�MNtq�QK (KKKKtq�(K�K	KKtqh)Rq�tq�Rqňh)RqƇq�Rq�hBh3h4((h5h6X   35852352q�X   cuda:0q�KNtq�QK K�q�K�q͉h)Rq�tq�RqЈh)Rqчq�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�hVKhWKhXKK�q�hZKK�q�h\K K �q�h^KK�q�h`�haK K �q�hcKubX   4q�he)�q�}q�(hh	h
h)Rq�(h2h3h4((h5h6X   34329952q�X   cuda:0q�KNtq�QK K�q�K�q�h)Rq�tq�Rq�h)Rq�q�Rq�hBh3h4((h5h6X   35582064q�X   cuda:0q�KNtq�QK K�q�K�q�h)Rq�tq�Rq��h)Rq��q�Rq�uhh)Rq�(h�h4((h5h6X   36177248q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rr   tr  Rr  h�h4((h5h6X   35815440r  X   cuda:0r  KNtr  QK K�r  K�r  �h)Rr  tr	  Rr
  h�h4((h5h�X   35939680r  X   cuda:0r  KNtr  QK ))�h)Rr  tr  Rr  uhh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hU�h�Kh�G>�����h�h�G?�������h��h��ubX   5r  h�)�r  }r  (hh	h
h)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr   hh)Rr!  hU�h�G        h�G        h��ubX   6r"  h+)�r#  }r$  (hh	h
h)Rr%  (h2h3h4((h5h6X   25327408r&  X   cuda:0r'  MNtr(  QK (KKKKtr)  (K�K	KKtr*  �h)Rr+  tr,  Rr-  �h)Rr.  �r/  Rr0  hBh3h4((h5h6X   35939776r1  X   cuda:0r2  KNtr3  QK K�r4  K�r5  �h)Rr6  tr7  Rr8  �h)Rr9  �r:  Rr;  uhh)Rr<  hh)Rr=  hh)Rr>  hh)Rr?  hh)Rr@  hh)RrA  hh)RrB  hU�hVKhWKhXKK�rC  hZKK�rD  h\K K �rE  h^KK�rF  h`�haK K �rG  hcKubX   7rH  he)�rI  }rJ  (hh	h
h)RrK  (h2h3h4((h5h6X   37202464rL  X   cuda:0rM  KNtrN  QK K�rO  K�rP  �h)RrQ  trR  RrS  �h)RrT  �rU  RrV  hBh3h4((h5h6X   37192288rW  X   cuda:0rX  KNtrY  QK K�rZ  K�r[  �h)Rr\  tr]  Rr^  �h)Rr_  �r`  Rra  uhh)Rrb  (h�h4((h5h6X   35880224rc  X   cuda:0rd  KNtre  QK K�rf  K�rg  �h)Rrh  tri  Rrj  h�h4((h5h6X   35851536rk  X   cuda:0rl  KNtrm  QK K�rn  K�ro  �h)Rrp  trq  Rrr  h�h4((h5h�X   35649920rs  X   cuda:0rt  KNtru  QK ))�h)Rrv  trw  Rrx  uhh)Rry  hh)Rrz  hh)Rr{  hh)Rr|  hh)Rr}  hh)Rr~  hU�h�Kh�G>�����h�h�G?�������h��h��ubX   8r  h�)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�h�G        h�G        h��ubuhU�ubX   linr�  h)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  (X   0r�  (h ctorch.nn.modules.linear
Linear
r�  XL   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/linear.pyr�  XQ	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to False, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, \text{in\_features})` where :math:`*` means any number of
          additional dimensions
        - Output: :math:`(N, *, \text{out\_features})` where all but the last dimension
          are the same shape as the input.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['bias']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    @weak_script_method
    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
r�  tr�  Q)�r�  }r�  (hh	h
h)Rr�  (h2h3h4((h5h6X   37195296r�  X   cuda:0r�  M Ntr�  QK K@KP�r�  KPK�r�  �h)Rr�  tr�  Rr�  �h)Rr�  �r�  Rr�  hBh3h4((h5h6X   35650016r�  X   cuda:0r�  K@Ntr�  QK K@�r�  K�r�  �h)Rr�  tr�  Rr�  �h)Rr�  �r�  Rr�  uhh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�X   in_featuresr�  KPX   out_featuresr�  K@ubX   1r�  h�)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�h�G        h�G        h��ubuhU�ubuhU�ub.�]q (X   25327408qX   34076704qX   34329952qX   35492848qX   35553728qX   35582064qX   35649920qX   35650016qX   35815440q	X   35851536q
X   35852352qX   35880224qX   35909536qX   35928976qX   35939680qX   35939776qX   36177248qX   36243872qX   36281040qX   36360656qX   37192288qX   37195296qX   37202464qe.      ������߻v�;���LV��i�7=ۚ<
w>#�c=�-�= x=f������=:Ǽp�1��q=��о����G�i�!>�>=	�,>p�7>��=US�<3�c)�=m�"=.�O<e&����=x����|>*��J=>�W�q=�X�*��ܿ�=1 �=b� >�I0>��>�(�=�����h;�:��] �=r#�=1�n�ү���RY>��K�x�����=���3���ڗ�<y�	���>H锽rY�<J\C=������=hMS��gp��T>ez�>P�=�/�-�(�Ś�>h��=7?�=�`��M6>Q��������S2��
��4O�=<�Է�.����6�c����� �퀏=c\j=������=�����=5\)>Rj@�o�žL�B>��=IA�U��0y>�w�<^�E�q�
��}�=� 
>�(����=j����<���.x=��M>X�@��G�=�%�,L=���@��=��
="�%>��P��?��S=��Q=/q�=.н/>!p���Ӡ=F�=q?B���J��-=N�d�9�����ֻ�֠=ƮP��]>C�=>%1����=S��Z�	<�D���ٽ����h���aw=��H����$(>)$�=R�=���>�C���K�(�>G'M����;���=`c򼉗j��vʼd#�=�>>��W�Į��A��a���!>=Kn<�|
K>��D>�S���S=_�=K[��)�o�/����=lx����>2�!>��f��b����=%�%�LgY=	�������4+�e�%>oB_�x$<�=�=,{B>��>�Dν��4��Rսsy"�mg��Iw<�z	��a	�J�2>L����-0�@ऻoN�����=8a>fꤼ�A>��=�q4��T>��x�9���F<q��;���=�QŽ'��=Jn�h�;���CJ�����=�f=�6�R۽�W6>�Q��^�콓o"�Oj >i�R=����� ����+�<�m�=%+=C酾m�=f���>�>'>�?$�^1��(�/���{�,`Z��c��H�(�*̔��,>u̝=��ͼCn{��&�=J̟��P�=���?jP<W�n��ڽ�q��U�耸�L8->i#/�U�C<��o���=�=��2�"�r>z���MV8���;`�(�U�=��=6O�[]�d���Y�[�y}뽲��=~�h�k�ɽo}�=�?�<xl<@R�=����E�>�Z$>�"���fr�q5T>�S<Q��=�׾�k=��P=;<�݄ ��UC=2��=��	_������0��n�ʻ)�<�?>���=�0U<����F*=�P����+=��`j�=�I��3R<�$���C>��K�U�5>xrg������L콤��>UQܼ��<T��=�*��l���S��j�k>kF�d���:�=�=���=�b`�"w�<�O���=	���?�q��P>	��	>�5�[Ղ>Eh��<��}��;M��� ~"=N�k>��=<5�ج4��ی<�=&�]>�Ы>T^���~��q�=m:�6��I^H�<x����;)�0����=�Ĕ>�w=�A�E̼�6�>�{>H��=�ߠ�V����z=��=A�\�k�
>P�R<�y>��½�̳�vn)� ���ɪ���=�ܑ=�ai�V�k=���=�9��8��b�@d��@��=�+��<\ܽ�i"<�$����T�>&�=��?>m��>��I<w>�">,;�=���=�:���=���=i�5�!|>%aƽ.I%�x$��TT�]�C=i��=��#>�d>hn˾��&���=!�>���=�4;s�=y%�:X4t>���=�sO�=�>�B�Ec&����=�6�<f5&> �V>�A�
j:|��>Cl�<w��=�Ĩ�����G*/>�k��=���=�ڽ�98�0���]��{¼x�*��2>����I�fc>r�=�=�5=R�'��r=Yž���:��e>g���<L�=e�O�i ƽ��P<!w�=$(8��aj=T�"=���=!��X��Y�<����0|��ɽf�Z>��4��>�<�P��Rx��|��p��䀸=���=� >��v��C�#���l����<tl��M郼cx�]k�γ��3)�o��=��ὓt{�u�ؼ|�;�2��_�<��>E�X��ƞ<Y�h>K��	���������=y叽!���i>xR7<w����;l\#���	>��=�2�>�:a<��=@�Q�Bt=���=Q�e��8��wQF�k�=`^�M��R�����=�������c��=��E�㕽0�@�:��=���={!J�MCP=l��=V�=K��CV�ב
>��o>�b���u�D@�b����m�.�Z໽�	+=���%P,=H�|>Ӳ��ؓ���jr��Y�=z7;��*���6�c�K��O>�*>�	��Tn<5�ࠈ;W׽!��=�M�=�>꿻�5����Sl�Lڱ� ���־��<�'����<��>Ƨ�|�ý�d$=���=�n> ��:����%���>�A�H��=���\I%��~���=d��KY>o�E�����jU��H1�����֖��p���BU>S�*�����ս|��<���&�Y�5�_�>O�*>F�J�V�q�9�Ӿ���w{2=}qU�T)>M���5yW���δ��T�x>2��G��:�L*>�v����<WI�D�FwO>��"=f��=��!yܽF�������ȅ=7�6���I��Pܽ <���Ϝ>�?��=I Z��i���)ýwe0���8>6:<�((�;
�`��ݴ=�� ���ٻ�����E�{�_�H�W�b.�<�ͻ�;6+��y�=�&>/6�����^u>X<��Y�s�/A8��l�V<�=�W>�l>���T=���)��'Q!��j�y���22�� >�@=��S��q5�~e������,�'�j�>p�=0�׽ʊU>���>�_S=x׽��8��T�[�x>z�D���;:<^�={��=��\�8�%�ʽ��N=d�::�Y��LY������M�p��=
uK>��=���:��6�>�߽�ր=�c�<��B�붡�B>��f��Sc>ܳ�=O-��N��<%>ݼd����p�Y���l(��1)�<�$=��%��2�<X��;�M>��#>&	�.V��PB��m>�a'>�����͞������nC�d�b>3��>�l=c*�=���=����b��+�=�r��J��=�^۽ �齊 =�[��
"�^LC�n�;���p�>Mм fؾ��t�v�粼	�'>�v}�������5=P�����g=��	�� R=�7�=Y}>�	{��d��}�=a�(��%A�/]���.ǽ<�>������=�v]=��d;Im�;h�!���4=�+˼������V�3���q���>�8a���W���]�* �<`�:=k�>?�~��nx>��&>�F�=rp޼32n��������!2<c��= Y�*)���䈾��1>�ꅾ��彁{"�Qc<�C6���4>3Q>k�=�m��
 �`�=�&�漼=ɱ;�ф�ow4����39=�n�b=X��u!=7>>�z��2u�����$(=��>ݽ�%���&=��=�����F=�)�=�7>�F�\d�>��7=צ�<M!�>�����*���h�,b��R�0��l>��%�Z$=��=P�>�u�>�d>zD�;��9=�h�>��<b��<z7�>|�>��ԼgF>3�a��#F���;a��oe�KC >o�=󅱽�.)�KD��NG���Ǿ
n��wn=G�:�h]����V��0'>�f�=�2��J�>�ӻ·�h���Cq��jӾq������½HV����i�-��>�)=�9=�%s=T�8=n j�5�p���==��}��~<���].J�,���W����| ->)5��?d�1ٰ�n&;x�P�x����<o$�<^>�A�Җ���<\=$��=�������▾u��>U�������v����=�!V�E�=PIq>�b$=�0꼞����龼sk#��+��Ѐ�>�>C���@7>W�>�,���7����=�H"���#>k��]��:
=L�=lٙ���޼�\�_�E�)�=����P�=-�T�FV�=*H��q���RH�2�>9O��E���埽-�>AY�=���<q8g�cC
�o��=�载��=Ug >�쩽wP��2������<���W������������=��Q� ��<��ɾvg0�;C���K=m�M���=!J�=;{�!b>�佯`H=k=>⦚�N6��<3��^�=�J¾���=�B>���;W�����>��=��f��!��	��h%'>J�y���N�{�.=��1>���p�:�=��=���}�S���=�=�>�p�=�i��$��V6ҽ	΃�����7�0	>T�0��=9O��� :��c>-�.�H$�c����6��L<<3��=�C�=@61���=���=�����4=���<�2#����=�gK>��E>�r˽9����2�=�I�u>%�,��3��N	��>9�>x򋽳G���D�(�Ž��1~7�͏$>��������vG���B���a���p���̽h!�=�:���I=ۆ�==�*�x�>�솽W�<kc<�C<�K�>���<�!�*/�=�8������h}u��9�w�����1�rk�<d�i=�/����>�=*>�$�f��=l?������}��>=�}�r���X�����߼��<��Q�/�=#�P>,.=�ҏ>�͏�K�-�_o�=�����o���i�o4��x=�n<�@>��A>�Cý=ص�6&�<H랼<Y��T������1�O?��K�B<�R����iE> I����\�ls�����9zp�J�\>G��<\��<��̼�~�u̫<��=j�\��w>�Oc�%�<�Y0��z½(��Q�>u^���>@��Wv�=G����Q6�����샌��ɓ�F*����>�'=�[�=g
�=H�B�uȁ�7�ռS)#>Қ=��=t^����<�>![��S->�}m;;ː=���Z>v=K�(�#�����=>�%���z>��<4���ظ �5\�=��Q�N)<�O=]X>�,�-�<s-�2���9 =\�_��1m=t�:}�����:�;=���=|L������Ԋ����9~��	>�>3 =cU�)�
=�@�)mM��Rw��ڌ=��齔j;}l�1�^ >I>*�� �=�M���+��k����üs9���k��R�Vj>2��=�·=*j1�ݡ��n�*�ܹ� d=��>��?�0��<O�M������ּZH��Z`�V!���p>1m�=n��=�о�">5�.�ʜ���=~����z=�<>�׽K֛>)1�>�����������>-�(;����Hh�>�!���F���<�6=�F=@�O�P:>�]�9fG=$ob�1���8U��!Ǿ���=��R=��<�<<�d�>�C;;�=�Ü:�i��*轟nh;غ��f�>�8��)<�=o��<��ѽV#>���=-�D�� >��v�-]�Q[��N.�=x�a�9�hP��c5=��\>��]�o�!�=�T���V�v+=��>ʯ����;	�q�����o=��;EHT��D��6b����>��Y�u��fR��<��Ⱦ21x��
���d��r�G��v�==�T>r5��<>��¼�F=x�P��Z�=�I�=è׽K�=��p>]D���i2>{�1�'��y4)>8M�>0�2���>E��=)�=\1/�{���N�鯿=��=��u;�@q�����~=��>�6`=f��=��߽��b>^�g=�������=:�t�\�x�?��9=l<���=��>���-��,�=N�A�V�e>�R�=���pcȽ�-���ݻL��i�<�k_=�s��� ���>>�LB�%	?��1�S�d�-��b>"����1=��2=�]>}QP>���<�d�<�k<s���A�=��=<G�޼�����ٽ�8;YO=�u~=�_��8��O.w>E,ܽe
�=H>�>Ȋ�>�>�z�=�h����<Y��<�==M��<*+�h>�3Q??���AO���\�-V���F=�o
��>�C!>��ɼ�+�=ڛ(��X߽������Po�=ɗ��ܴd�^a>r�7��=�������i�>��h=�=�=�W�>��K�����܆�¾߽t?Z����=W2=�3�;��=�3�=���=y н���=I9��̰=��Ƚ���=^�����W��=@>V�U�ڜ�=�W�=��=Cʼ���uQ��J�<&�"�&ꖾL�g��}ҽ�f=���.�Y�G ����=��ݽ���gځ��F�����9=G���r$���[=����E��_�ν+y��R�����=�T� ,��>�>��d>���<a��=(%��ws3�ʼ�=;�.>X�н�e�=R+>_��:^�E2�¶&��">�pl�<�B�w�8���%=n
�=J"�=��=q��<�$7���	��j=�����>��v��x>�>��+=�iq���<��>�Wu=j�<V4����>Th�=��ڽc�<s3f�)ӓ����=�92��_�nT �g^	��d��kp<�#=���F����=KLL�լ�W�=��>���<���O{>h�潛\�>�Rb��/��F�'��U�=�f;r�ɾ�S>��5>(J>�xԽ��f>��+����g	�<��L���N��;>Gx\>�6>�ʾ{��mJ�=F����>�=T��=n/�bG��n�m>%-����!E=3Y>dZ����:�)��xQ�#��={�<�[�>ň�<
	o�~�>��G=d��;:�=H<�3>F�Q<Z����j�	^L>_Ǽ1��/:��t��K(�=�=#m=����{#��O��Jo<���=��=5us��A>�Ι�ܝy����>��=/K�<�T=�/���S�hj�=e�3���&���>��L;"4o�k彁�����n�i�i���0D�+�>3�)��W��鴄>�٤�ZR�b�Q���y=/�F�ñ:��	�Q��=��r>�^�>>��{M���T	>��+�>'\>nM����5=�������<nV�����<A->�ͽdn��>��(܁���>yp��ˎ��h<уJ>`�>gl�<�pP��a�:�h��=o�<�;u="�<A����
��|�9��� ��Y�\�zr:s� =��U=)u�=�	&=KyԻ\5�����&[>�j�<	���������C��wF���څ��?L���>N1�=�x�ר>�i� ��{�r��=AE��载"�2;`�x<ǥ��6���D|>���?>i~A>�����hq9CB�=J`�n�ٽ���<��]=����:Լ��>i��{�4��Z=C�W�U<���=��k>�����<,w�z~P��.w>p��+3>h�	>7$���b:x�e�����Ò>7��=tq���D�=��A=0���,�|�ڼM�X=���䗽�
5�=�Y>�_G�ʲ�=��ɾ�E(�A�<v��=���<l?���CL���-Z=ܖ>gU>'� >�V�����L��v��!�:h�>e>���>&x<���1� >�J=0V5>��I�h���̙��5�N�<���I�=�����7;ឥ���>�F@����'>N�=��s�:�+>����Q`>�)>�����==|OU>� ��"rf�����j��"�e=1Mj>׃��$�K=+o»f�k��>�Ò=�p��9=8i��\=�� �=6��=���ؕ����	*l����=�	�=m����l>�W�=��C���ۦT�����%IT>�G��h�C�ɽ5����Z��?_9>��=�>�H$��덽ы>�3��_g>P1e�I6�=t7j���>
x��Dn>V'��}̇�l��=e�<�ҽ�{�������<É�=��]�x>��7�)����Q��ǹ<���¦=����R���ko��ߩ�����-eS>kR�:T�>�����ý�x�>���;"��(�S����È���l><�s>3g=���<�r������ ���k�>��;�e>%�>�9����S=�>P6�\����-r=dD->v�X>\2���[_=�G�<Kݏ=�f*>hEݼOٸ�^>Eݐ=�"���x=�8>!����=>�6>�4<C�9��I�=��b>�>�>���䞽̈́ڽ���Gu	=;I��jde�&;�<��>���d�ǽ��&=��=&�3�����z>J�<>?��<����H�ml�
�������6��G���6,=���<zj<&�=|�F��.D<����J��������<>�п=��@�]%>���7�y�<������=�֙<;���3>������q�0�=VS�=3i��X4-=F6<3����4=�ۊ>�[��"�~�c�a=đ��ݙ�<fH��Z�=�K>��̦һ�p�<�D�=���]�����ڑ�\<��:��hB=�)>Q��=fս\,$�3�!�&Rʾw_&=WG>��>-?߼�Y5�,P>���<���e%u=�@=�p�<{�H��7�=�3=���L=j�<�`>U9>�&�<��d�g�<Y绅�/���썍��O����ܽ�?>���=t�s=��=6: >@<��Ub0����=h�>�'Ǽ��4�rʍ���=��<�����}z>��Go��f\�?����==�W=S�==�<<m��<>e>D=�e�<���=~����TR���1>�흽~1�=�a���3�d��;I���y�=��O���̽�zw=y���:�GE>#(=a��<�)>�����=�K�ɃƽKE��M�=u?�<�|����ƽ�~ >��>��>�B>�'�|I><Mc̼�{��L+=�Fx���=[�f���{��[&>O��/�=���YX��i��Hk��5�9�������=2>q��=�Q=���=֗r���g�
��"��=%��>T�<ꥲ�8"���9/��y�=�:�=�����#9>B�>��<���V��G˽�,�=x���;D=8<t=�|��~>�^߽�.���3��N&�Q��Ǿɽ7D�=��W����>=F౾a��<�k>�z�����FiM><G7�wa>>4�;��̣=urǽS������b�ݼ�-���۞>I����ѽ�I��C�J���H��=m*�=��>���>�a>�a�<���<y5��O�=����e'>I�$>�|>��=+�=�*6>���6�>�����:�Q�U�\��<<T���26>H1�ԿI��>>W\g����<+U���>���=� �>��;�D����?>�%v�e��=�i潵.�=���>��&>��9�
]R>��J��I�>g�=���=����w��ܷ�=^�6>�����ὂ;X� M�=���<�<=���h��:��<x���XR>ɰ=�$��	j~�+���8L�=��)�3F�ċ���]p>�9e����qh��_r�X��>�B>g�=7̆<L��=��b���I���\�x��<9D��'��e?==t�^�����޽.>�>LP>Ӷ�=��$���߽�T<�����I�>޾����<b�.���m���ٽ�>[�;>�=(�d��*^>�4��0D�^���^>���%�<>+��ֶH=c4<1Ds=��f�Ԛ㽆���h>a��ru=|�>��\�>Z��I;�<����� ��j�=�<����s|���L��������&�o<ZSC�[yW�D��=���=�W�=���<�맾��-��3ɼ"v>��;����F��5&=��{��Y�=�C��g
4�y�.ɓ<��=����Y�X�[I�=ȏ7��=ҋ��i��={�4>�W(>��	�z���r|g�#:�-�[>�S=���=��S��y>�I�=�J��f�>�۽�9����;>���?�����ϔ���Y>��4�����$�Q`7>�Ok���"�C�z��=��6�ҽ�cú;�D��=�=Wm	=x�+�]ｍD#� >��>���A�!��k��>ɼ��:���F��9`�5V��t��=��=_l�<��{=��+�@��>��5�����B�>u�=�{�<�����������b�P|�;�{"���=K'=D��=�I������V<cy~�=�t;�X�<��=�u�<r>�P���= n��� ����/=�7�<�=�s=�}=@�)>���=�AƼ�)�P�;���>��M��H���p�=����;J���!����w>W�=�P�=F	��b�Y�ͷ���+Y�DO���r>:���<3�=>W7�<H@����=��b=ē =�V� =��=g����o�� �v�.B�М�DA�=:V��U{<�쪽V��=}��>>��fi{>����Ԓ��.��������>�!|��R&��=���;I�<
�=���Ǐ�<�؋=Bgd=z�;��=���;����ˤ<ڤ��yM�>��l�Y>�U.=�J>�����#=�G��)�� 4 �`ǣ=����A��/Y>ʁ��)ݶ��aY�o�"<}:\�M-�����
�<U蜽^!����`=�n$�n��=g���=2� <4/ֽ�Q���:�>��0���>晟<ݳ&=VTA=�1�=6�ϽXl=������b��t꽜��=	H/��E_�B�ؽ�-��f7����A��
�=R��;9*>ygȻ\`>GV�<kD�w��=@m�=	Z�;���`����½�֋=B��}�=1Yo>���=��C>��S>�_%��pl�(��=�>=�=�Fg�G�=%L=
�#T��J��=T���L��<����&���⽑�)�# ��^�(��׫�,�ؽ��W��(�=9=��=��ǽj��SЀ��伽2-�>��ҽ�<����i=���N`*>9���44�q�p>��?��5U�mq{� �x��=��=��@>XU=�,=mFb>�����J=R#n�I@<ǩ=h"@��c�=uC˽�8>6�9�?�>��D>o��3��ʜ���3�<>˯>!B�"%=���x��=�O��zD�=�b>0��gU�>߉?���>6	�=쭬=j��3�=@\>�/=d�e�=�?�ṽxW���8+>�l���=��v�<�N9>��n=��=z�=�Vd�8�6=]��=��F=>��=��>X��=1���A��խz�Gs=V{�;
>�K�<���bvk�zΪ=�{ǽ�I>���qx�<N������A��9?��,��U����<�>��J>v������T!���|d����=��*<���<�4�<]>>�dl�3�-���=�i=��	>Rm�=�Q��O	��#�=�!�h�j�>/����>l�B>�ൽ.�N��:�<I�&�
��{������<YG����=����$�8T2>Φ���r=��u�Rʎ>Oj�=9e�=|ѽ��<�~��.b�����(�A���wȼ�(��Ѯ�^r>hzҼfp�=�/>ܟj���=>��"`�=�g�=�c!�	�@���]>��H�w��=�r�N��K0=d>J���F�4Ï��骼��>y��<��=m�սDc��b�<�ّ<����k����=��j�&��=�}W��c=�ֽIwq�~��a3<�O>�C���^����='������=���=^N�=-ٌ����=Bh���ᐾ�H�=��T<�U���-=,)���m׼��=T�
>z�=�t������td<^�R����<0�ٽ]������>S�0�,�����<\�>Ղ@�2z�=ZPd>L�G>����L��Sz=��������n=��=���>V�9���1<�=�G�;�5�=�^ȼ�>o�>�J��<�%xѼ�<��9��{&�'��vj���=3P>��(�s�����=�r�>��q:��h��=󝑽Q���ؑ�=c_�=}�=�°�H�=U�;f
2>����r�J�Ͻ�R<��8�fK���	w=랉=g�=�\̽��
=+�H>t��g]N�����i=_��2>y���5>�����;>�C��I���=L7ý��n=����㑼�i������6|=�`L>Z&��(ҏ��d=��H>ٴ>�l��W����.�=�8�>�mG=Іh�p-��rt�H
K>g�<%��=���ny�=aRh�]F�=��� VR��O/��ul�J)K�m���ҽ�Lr~>�M]>R��3N>�:��Y⽡2�<Bo�=�=>m��z�𽟎�=y$���c7���6���J�플�P멼��{�5O5;����� ܼ��;��>	�����(��Q�~=���>�+�U|@���>���=)�q=W������=���{s�=�1<Ƌ���"=�S}r�,��3�>�~P���>���=�8>�=���ּe�!>mE�=��=��=��=�\>���=]��=(L��a>���=x�J>�/̽������ýҔt<PC�=��=W�=9���o���>��?�6�>lZ:�4��%�=̋��鏤��XI�~B<F@"�#i?�ｗH^��4���|��\�x=7��<�T>��=Ҷt=r��=�ᮽ|9��C>�N==/=����� �{>nM�=a*�*n�=��:�5��{�*i(>"U�<g��aڽ&Ԕ�nv�r�����@>�	�=;���X �"�Ƽ���;��,���L��{�<��&��i0��wj=Htx������/�=<� ��>>U=��=P�����L<�;���>�#�A(���5���>�5N����<7�[����ܡ�=*�[>{̰��F.>�w��U����r>Z�F<vɼ�?��$>U->@�x'Y��s�=B�̽�^=sv�=�'�>+̽�����k���c|���輏�)�w�-��T�/(� s,���r=�m�=���=E��>y�O�ο7> ��=�;>z������E�G=O�H>B�S>d#0>"���ڕ��s >f�>'A=�y=��>OO�=��>�b>��V����<��>�|=�Y.C��R�,Oc<9b���ek�=�NK=�>�=lP���J=���=��t>�/h�V-�>re����	>A	4=(�e��)�c-��>XL���=�'^=�9Y>m.���]�D`*�j��=7���ȟ߾$������>����6�)>�e=��=���P�ؽ��C<R6O����>7x9>�I�)<�Ό=�ѽ���^m{��4�>���K�<@;�=���<�b�;��m<-��%�ܽ8>�=u>=���(9���1>rϘ���󽭋��Ķ��
��3�>FP�<ZX>��G��LQ>.D�|���;=˨���$=s$>�*\��
E>'f,>��<��V>�v*��->�⚾I��2���J�.�e����N�<����*>��>˻��I-�x)�>���<a�G>_n">��6"���=\����vg<Ĝ�=D*�;��>_ʽ���\�"=�-��O��=eԬ�{�ƽ��N���<�X;�*�<[��'�)=j�x=iS`<(vJ>�-�>l=Ϭ��X�<��i>~�O���=��۽Y�*=����ˉ<(��=�"(�~E=���=��R�E=/�Y=��8��=wH�<�N�>Q��=M�k>��>% 1>�=>�
>0.?�S)�=�, ��c�;�ha��'h<�/������9�ǻw�>�F<�T������=SH�=mۻ�di�gD>�N�=�ȕ�\�q��aؽa2ὂY�=����ǁ=�f���ᘾ��=�d�==���=q�'>�սI	s���=���=
e���h�=39��?"�:�Z�K��R�6�/�ؽ����Q>����]Q�;;s̽�vҼG�5�<��=Cʽ���c�>��>�Z��>���_8>N�=���=�bd���=�ʵ�j��vC:��7<q`�9����Cv�T��<���<�;�<�3{�W�\�/L��tJ0��懽�'>�>=�>�#F=+[���W�>�_b�I�c��]b=��;�	�.��t�ؼ�
Ƚ�D�>P�W�U7�3����C>I�� $l��N_;�<#����DE>�=,�5>�d��̓>cw<�g�g��+<��5>�">�R��>���=#��=JPý!�=�$�q��ISw>��>��>����&�8�S�p�=W�=̤�j��>�1�O��<� =��m=�������=�2��?Km��������=*����6�+��<�	>uZ�=�>�9�="[���$t>7r&=�<��88�T'���)>7W�=��:�&�����K�Y�󽻮�ߖ+<�H_�=P>=��=��=p�g��	>       |.<��G:��';�*�;��;-;��;���;Ջ;�
;+�;	�R;���;���:��r;R];��8;��.;��R<Ds�;       3�?�D�?�(Z?��I?{�^?1��?_D�?���?�9f?�A�?�J�?�َ?�/J?��u?��?�
q?��k?Ԩ�?Wce?�?      �eU�t#�>�p��cڽ�4��%1r���F=�g߾`��=�؋��`s<�_�=�B�;k�4<�8E�x���+�]��9�=5�޼��>���E=UY%�����f->�8>۪��b�t�+�a;�ٞ�Ap0�8?u>��>U8J=dt���-=�(ʼ�v�<r��.7j��1Q>E_>�a�=���GKټ�(��k���E���̼Q�9>�d3>S�=�L���!�F#�<�P��������=�e>l;>1dŽf�Ծ�Ͳ�Ǩ@�3�¼GC�=���=�Խ���a7��R>�9���>C׽�!S����8�U>Q�ּy���/2���=a����L ���I��>��';���<�*�����[=�����=����F��=]��>���M�t���=t�ٽ�tA�N�	>|��޹g��%B�T6^>#��=��d��Q="���n����R��7�>�_�=π�=2��<cZ�>�6�=1gS=�>?����<<G=�����>=�"��e^���<��N��������4=~S�=�IU��ݜ�i#>�V꽪f8��<'=�T��w1>?ں��j�D�7��&�򑻽�B��f����3�>Ƥ���ٺ３=i�>�Tq>պ�F0��,&ӽ�N��g痽���<o��;�T�+P=�s��(�� d���]꽭�>/9��@(�q�C>K�I��
������S<=�']�8��=
	<�JW�Rܓ=�@j>3P��c�F��*P<FH	��J�=�墳�DO�>�p>����1^�鉔=5³=�c�j��Z���>����=��H=�3þ姱;��}�f����H>����e�=Qu*>��O>=\�=�,��`������=I�>Q3��lJ>5���0�6>_�{=ʄ���	�>�>��M�
��=򻘽}��C�GZ��N>�,=�~�/Q�;���(�T��֐=������>T<⑾��������Y=���=�T^<��=i��=#� ��ٗ���F�qR��C�=�`u>����r��$[�=ݬн���~@>&�5�x�S��ֽ��[>J�Q��T��$�8�N�׽�Vh=G_g=捑>�H>�	�ذn=���= �0���r�R�\{�'�=S*6>���B�2�4�	��=�=�br=P+#�Z�*=��.>�6��E��=L;�DT3����%�=m�^>C�'���S��[�>EW>gRG�C����D׽>Ֆ�߷���|:��t��Fjw>��=���=�9ͽc�=��<r��=D�ɽD�=ۺ�M2>2�� �^�*�ɽ�<TL�>v:����0���`��-�X��< >jv=m=��#pӽ)��<��̾Pp�>�ɒ=M�->c��=��⼄R��<۽
�=�v>�q�h3ý�W��ng��F�̽�3>@rս �J=f��=Tp4���<��;=��W>�='(�� �=�'��-��5p�Ql�=;�L�ؼ?�ؾ�m�;���q�ݸ���>�C⽿�>nb�=J �ٓ=hzJ�h���?ͽ��=c�ʽv�
�:�;��9>#�M��⓽=>Βb�����F�������!��V?��Z;<��,>Ǯ>*����1=��= ������8�4>��j>?ɘ�,#ֽČ���"<�J���"='��<@H=B媾Mɥ> M>�Q= $�=ׂ�=J�C=$43�j�<�̬��O���U-=�@ݽ.��=�?>1�|�����k�ٻ��C�(�
��|*��u >���=��>\�н�i-��O�[��<ܜ�=�ʜ=��j=���ךj�/s��;M~�G�+=_Pe=���=�f=�>r�T�UW���Ѿ�D��';>i����)>8��.�+��9<��O>N睽�Z��y�=��C��Ǻ��G��\��D��>�fB>�M��z�=�+>?�n�5�=
3���	�H>�8	�?'>�Ac>�<=��� ���Z=՟d��=��ɼm���x$>���=�=��=��#=�@�=rj�>k�|>��=of>mr�=��󽆣н������>�g�R��9��=<�����Z�J���=��cM<2�F�ǽ��"=�#�>D8���#>zes�v��=��6�}��b�<(�=���=,L���ŋ>^�>,�������������̼ɩ�=��߽��۽�M��L=�       ��             ��Q�V��=Fw<���=|�@=z�$9�-�=�m=�Ν��v+>4K�<��>r�;=��=�$�<���=H>}h��       ��      @       N]�����Y$=����>u��=��$=w&>��=i>��>,��<In�<k^�;z؊=����,>T�=��/��E�=Y�B=ǭ�=���b!>1;�<��}=�6=ȕ�=��>n�>��r=��<��I�jx=J|Խ-d�=XZ<���<�Ϥ<���=�dμi�>ox>1M���|��:F�]�C9�/�:�ɺ;�]�����<?�%>��3�\���9�=�^�=�"�<TG>w��=�x����𻾮�<�_�=       ��?�w@1m@��J@�<@�v	@�MK@�o@NL@^�A@`��?�@�� @�W�?��F@%�@ߞ�?S�f@y-L@�	:@       gɢ>f��>�U?�{f?�W?��?��>xƭ>�K�>q�N?n!?R��>��>cI%?�?k�>���>(3�>��e?��>       r=����p���|ֽ^9�=�.>��J>�*K�����=�o5�����jY����=��f>�DK=�W�����m�=��       RJ?�|g��N�;�����}��D���ӗ��슑�5?�����	��J��{��>�cƿˡ�%_ ?�Ȏ�҂?�43����       ��^��>d�2>�x>�l=�/:>���Z=9	;�W��um�*��>+�B=YA���!��~�r�P�e%�=���=�9h>       t]?Z�?%l�?'ǐ?�6a?�qe?��?�!^?ր?ޡ�?��|?%ۆ?��z?m�o?r�?;b{?\��?Y+d?�N?t��?       ��             �H�~	_��l�p=�f���<��X<8�<�V�<r�j>�Nx��I�<��=���y��<���n5=�)?=��4�Ȧ��       n�H��f\��ʒ�H2|��o���)��r��A)v�Eb���D��0I�)���H��*:���R���;P��ͯ��g��f��      PD=n�\�]�Ž4�-�Ÿ_��8>\�A>E9޽Fh8��һg�=�Uv����=Y��=-��a;=v�<�&=�Q^�y�=�D=���_v>��s=�оp�*�
�(���>i��=���=Ԩ�� e<�󻾙}߽�a�6Ut;�-9=�k�<k�'=4�a=0�L�*��ʼ|=G��Q��h����-���}�S2��g.> 
>����wV]>��\>زK����=?����;��KiI��e�=.��<�k4=x�=vY����j:��T>�F���=����`>���}}��������!L�>ꃃ���D�u����խ*����>eY�=Ꝿe>��=��+P�a2[�	ۈ> �5=���^i>��%>�5s<!LU��'���2>Q椾u9����
>�Qu�ܧX��ƽ⋛�u�/>}X�5��<:�:=s��=Lh�=�{>{�i���>�W|=y�{;<��=��t=5n���e�'`�f�9�ӏ�=�a~>z{����(>�b=b���M��W~�4>mJ�=⌃�>���$���e�<-���D#�%��<PS=����4->Ӽ�=�����v?�y�=�W�<v�o���	��e+�6~>u��=�|=E�/<��N=vངe�<ë�,�E��H@=���K%�c�<�<�=�`1>��:�l���K�ӽN�>��4�c|���>���;	Ϥ=K�z=\�f�\Z��Yθ<�p	>
Ʌ�g6�~u��ɽ]��=�����A���X}>N�����ǽ�C-��h�@{>6��<�G��Y���N�^����n̾f`j���˾wڃ�����:�=���>�{W=�?	���<s`����9>8�r=��=V?��n>N׽=nW�.�:��=���=��=b��=j�w���Z�ȸ�<nQǾ��/>M	�;�����<�z�=Cᄽ���=C�'�gK���8Ž��Pӻ���=��<:����O�B��=�1��g�%=��ܽ���=��=��>]�=���<��>�)�l��d=�C������*=+u@�Ip�<s�>[����;w�P=�&.=����q~�XCl�Y�g=�侾��s����=>B���Č�߁�=�E]����w��@K,�Uq���?>"A�"��\+f=���>�=��ս��=�	(���ʽ>�@ͼ���=�<��,>O> ��w���MI��Ś=��=�}�~��=�Z��LWս�DH��<0sG�[C>�pz�lPѽ&�=���=������>��>�N�my=�m>n��:9��=�P�=%Pg���%>[�ؾ-2��	�<Ա	���=����=O���*Y�^��4��7C����<��Y=0΂�g�=�	M��%��<�(b��=������02>���C�K���r��'2=�>�������Za$>��G=����-c½k���L�=<iݼ�2�X��=oi�=�"��H��I׀�ً�������= �ؽ^/�=�=�u�7���h��=F>�AC�/�R=ɸ�jb���� =/L^����=i������=�ھ	H-��t�M����T}��ǐ��j�=Fӽ���=S���7=uX��_�>C�<�o�[0�=����d�d�W
�= �t�������=)�<葫��<>#�ؼ�҃>@M�=���0�R���4��O�m\���'��=�[>�@	>ΜS<!/������^��=�ʶ�Pj�;zL�<�g�=]�#>k*X>7~�=u|�;W�u�<�X=����jO�H.<��@��H�k�=ŭ�=�lB�"
<>/e�;]>b��<t�K=� >�R��_��b:�%>"Y�=�A"���̽k��\2�=�����;n��<��;vg��[Y=!�<L��� �qy%�g�����=���>~�������>�n���A��h@ͻ� +����=��=�QS�8��=l�g��ӎ>�<W��]�=��J��n�=( e=~X��!�����=%re>�j����=O��=�6H>g�@>�{��y[H�_����x�ů>5�G�{}6�_qj=so�<�ܛ�H���/=r��=���<�<7��(ʽ�~L>��b�i�Q>W鉽�j��P�=�˽R��p�U>�zY�q��^߽,��{�1��]�=�8پ�n����l����QzR��r���g����'>�O�=�sǾV!���<>uH1>��A=�8�=�Z=dQ��D?�<m��=��Ž��ؽ�Ͻ��=�O}�(�>}[�gƢ�A�=N�">�tQ=�v<��̚�<?����=�"��ť<<�p�9��u�<L�羌|��z��_4������l}�=`�S=WT�=חn<Y���G�-�z�N>�o=��ս��&��|��C���0���s�=[�	�ͮ�=�=��Ѻ=J��Ǡ>���=V?��G"=�tX�=o��l�j�����/F7�EyB��Q�c3�O>;'���o�=[>�=�0�=��=U��*��=Y:<�1�=xʆ=�Z���x:���>3�����c���?>�<�	�=׈�<�%>�z�Wr������:��O辉.>'���&>(¼=p9'�Ao=mfb�x��8#��c��\麜FF��tH<�����X�����-h��3X��M@>���=���=1��<�:������j:��_�ܛ	�\n>/U�=��=��DB>(��Hb>�O��-:ͼ�|>�G�=B>��=�}�F.�<�P���o3��m6���n����<VWF��c��Ò=�k���������T>b�˽���=�=_E�=Ix��s�>�>!>*HH=�6#�*�I�Yp�=� >��X>Tcý"3*�3P>���!>�E�a��ڵO<����N�$�c�/<y�����g<j���h����=�A'�&m ���_�I~���Q��@�>���!<k+ʽ6i���F�E�>P`�<�d��@�=��u�w�~��%7>R�ҽLa>\! ��}=��9=��=DԾR6%�QN��Wg<Ά�������L��D��Ĉ�k��߂��~=̋>?��=��]�`M,��Sx��s=���[ϯ��QJ��uľ��*��1���G(��̈��<H>�-=���� �V�=w�����j=UD���f>�fe���<V~����%�[��=�%���-}���^='
�<3Ķ=���=t�[<� )�C<v�H�н���Ǧ�=���=�(�=Ng���0��Ѿc���ễ��>�����i
�P��ף�=A��=2��=Dљ=z�n�(�ǽ/�4=A�\>B(����=���=�uþh7ԽX������p�*<�Fh>嘽�h�<�����v����}$>�BٻA��rX&>�p�<����j >�9����
>K(�iE��k��<r�ԺuG<54�&@;��6>��>� 5��K�<}�l�w�g>e���U���Ys\��Ī� :W=Ɛ�KY�j4 �~���֘������-Q�۳ҽ��(�,��e�{�J�c�2m>	�>�뒾0����FY=�b�������d#>.߼��6>��=�=���=ձ(���B�v�
>x�>@m��=M׻����vc��B5�3+#�󚍼��o�O��+<�c.>3�L>��=����U���l�=�ϕ=|_�=��0>񛔼}x���D�H�8=i7�;��>�8�=$):>ك�>ћн[�%���Q>�ܰ�%v=��������,EG>���P�->`�k�q>=Ǧ&=��=]�|�5=��<��@�͖��D�6�پ��v���J>�[�=�����7�<��I=��=]�R>R2C��T׽#�U�~1�W�<�m<!̼=E�>k��=�R_��dI��N�<�eW<M�;3�㽢��N��<����?��=�=�=�ݚ=T�F�,�=D(�=�fʾH��<9�5�F�Խ�+�p����!Y=��ڽ}R�=�u
��D�BaO>���=��p��{=S>=l1>��F����}�1<w~>�.���a]�sܼ�N����(��j=���=6���"#�!�м�^�; ]�<C��+:�A�
>B�ؽ�Z:>n#}�����È�w�������C7>�p�<d����=W�)����:������<q�=D�h�d=�N��=Y	=��W=���X>Ҽ>>�%>HQ����>19����w�8
�VD@>:���X�]>��q��;����|q�1����>��Ɇ�=
�۔���4l��/��|�=�S\>�d�<�!�<?��=y��=����M*�����ǽ�E�>_=Y�|)=���=�=��_�m�ʯ��"�O�=AH���\����M�]��a򽆴B���">���.s������2;tQ���#����:�o�s�úr�������,�=�dT��"����)=��0����3����<g�=�<�)h�����3x��J�=�뗾���=�y�K'����>ª����2��I=���xf6>�8����־`��=�>����<���_X�=�v='����4=I�ν�����0��B*=#�F��d_�Pd>�^���E����k=M�ʽ��Ľi���DD>=V�(�`_�<QY\>z���������=h��=T?�=3_��,��=̿`=��־��-�?B�,'��þ<��=�+P�Ђ@�=�<<�*�<?�R����=�y��U��*��=�7ʽأ�������D=�e>�������8��u>7'���]�=�>��Ƽ��V�9y���`ὕ ׽�"�<�{h�$����tѼ��N=��-��;�=Lͽ�����ty$��ͽ�uz=C���j}ϼ*��8�G������L����=]���[(>~�P���="%=�a> ��=LK'>��&=�a���.�C�[<J9）🽫�T���;=������E�-4+>K�j�>둾+3�=9\žx~�4�f<��r��8�9H<v
���Q�=�X�;E���H�>���;�=�6Ͻ��=˃�=��d��F��c�Z�]K=���n��(�>e���^8>�QX�-He�mZ�=���=�Jv�y�h����Sʽ�
����=P�����=�9���=h�˽{�=���>��Ѽ�0�;����4 � �>���)����o�]�">x�=^4>h�&����=�,�=VE�υ�=$ѽyMM�HA�U�3���\��;���=X�=�3W=_Α=���W��=	i��[�\>�yg��ڀ�����A�>~!=t==&A�*��=�}�q@��XP�$5�=4��=W)��4RC��OX<\�O>G3d=��˾� :���P�>��=\�D=	V�;������=�8>y���m���~�m=ʷͽ�T>�0���,>6�����e�'*>Y�3��p� ����=�Խ�a�b5=�&�X��=#xW�����TT�<?�7�>��Ծo�<>��]��U������pa>������糿���S=AU�<w8���\E�|xn=>a���D�&��d�� ��Dm=�q���z,�I��=�Ê��T���ڗ�X�>�a>^�=����X�b�T�>�tR��M�<~>��3�[���=��=p��[1}��2,9�Խ�@���s=5-���F�'2y>\o�<t,R=�֛��7�=C��+Q��.�>��=w��=��=���=��ֽ�g��rE<#\���ۑ=g)-�BCJ>T��L�b��о#-��s�><O�异l��I�������쾯���]5>����<��ol��>��ѫ��5���z��ֽ<��r=O���ea�0�}�:���K�q<Fļ=��;�:~�W����=Q>CD�r
���q=��#��駽�i������k<��=57>3h=��=��<��8>�lb���vJ���Խ^�B���þ!�R=�d�D?)>��]���>���=�b�V&�==7<�q>��_�Y`]�c�<�e�=��ѽ��>����2�����=��v�g��>%\��f=<Ш���^��y�=X��Û>��H�4��!1�E�>�۽i�=�H8��`���>ix?;�i.=%���3�=:��=�<='ݽ�����{�:'/�����G?�<#�X>d�Z���>�|۽s�d<��=�=d0>�FS>,N�/<>a$��w�)�;���W<v�V+N;\���>R�དྷZ�=���=]�o��C=�o��=�6����=��a��S�=&E>q���n�������<�8���H��{?���!���=,��=J�Y�e>���>zU�7��6?���9u��˖=w��й����=M9�=	��=U�(��=ڪ��*������O��OG>���=�>�B]=^��&-�<,}=�=>�'½aDB�6T��۟��G������	�$ :"���%�=�>�=Į�=�E��d ��\^>�<K�{���褽�o�5�����<�=,�r��M�ѽ�=�b���$'���o=���;�C��䕽��˽~��L8S>-����P>���=rm�;�߽��>����}��=lU��]����"�"ڮ=�?H=H�����*�T������@�U=�m>^���R��x!>���o_��cϽ4�>s����m�<�pp��=S��U*=�l�=0�=��=��y=�߾�Ƹ�h�>d>�����="==8K��·����������y><�ϼ ��Q��n����=���<͠����=�	ɻTQ&��4I=}�/�=����W��	��=u�=A���R���ܺZ>=�ٵ�M*��3��Lr��-w���Ѿ�0۾@g�;��J=o���=Z��[��$��W�����j�E�)>�s�i�=�q&=�xb=�`���|���_=���V�,>��9=ʏ���I�ۚy>������y���j����S>3=��e�N.���0���<��������ؾ��O>JbֽP�>��P�D�Ue�;��>}�>�a�=L盼~P<�BY��3����u���h����=������
��n�y0z������;؋�=_�%�!ĉ<�x�C獾Ș��%<����l�>�\a��#�g��=�FT>!Ľ>��=ľ�ƃ=ug���H>	љ=d�-��Z�=����pd��P��L`��*���������n�K>���=AFH�&\�<�f�#�+>�5=�>hw��G�ᮽ9p��4�c��7�<���n?V<~�=n�&=�ʏ=�>�3N�}�h;\?����r=��=�.�=WH����K���:���ݽ:�2*"�� >���=�ս��>5�3�C�Ľ�8$�Z��V>Hj���sS>g�ѽ!
�Ħn�+h��o�=�F>�����蛽���=U�)>O��=�>���>V�=��.�	ad���=��ڽƷ�Ο>(Z�>N�a>�tӼ�4�A�<=����<���=�H�;&`�4�w�>3����Nֽ��Q='�1��۽�%����>fx�������=_P�ǰ �za<+�=倘>"(����>�Z.��=V!������E=�O�=qM\;ٕ��M���K�y���O�V�=[v&>C����.����_�\=-+=�g��u�g>��=�B�=ɷ"���=�%��O�f�/��m=��E�<B�X>d����Z<��v���0�F݊=!���=�1!�_�=�@�����=9�">�Ƣ��BӼi�0<*�R��H=�s�=W�:��]J���<I վͧV�ŉ�eq`�qO����K�W���(�����N�S��l1>{ ݽw�н�I=l�*=$���'�����>6�a>�X�=(�<+K�F��=x�8.�=x���*@���"��,���
�<˒f�]d�!�[<�_�;�dY��ek�މ�=8�-�R	}����;lT�2�!����=F�Y�w�Y/��(�=D�Q������A�=+�=zH�l=o8��p@���>S> x�<$��<;��=׬�"���+,"�i�Q�����o�=ʹѽ�O����ཧ)��)VY�ٌ#=$A>շL�#R=�꽞�Ͼ�|�>�ٔ��ui�o��<��K>�yȽ��>����ξ����@b��6�'�Ќ>|�=��W�j4~=q��`f=�ZĽ̍���7=��=Y>��=<a��=�о=����^��;j�|8b=�	=�鐾�ؽx�=S/��:��[�0�K���	�@cs��G=3;�<�8>P}��s���>�B�PѾu�@>����� �U��{�ŽY[���=���b������=(eT�aݽ|��P�<. |��}��x�E�:؅=��>�Ì=M��={p6=V=;�9&='�t�Loҽ[���㛭���s>Y:�h�_��}�&��;$kZ=?N�=!p�<� =����	���:�	��=z6l��^�����|��;�r/>�<��ǽ;�K�j�l�|	��H����O>�+����=FKH��
��f/�v+G�9�K�>�=h�Q��i�t~�>*o�������&�K���/=����s=t����$�=^D;�J .>����ZT�]��<��/=Ĩ�<5��n%��f>-1���;�[��)�=MJ�;���潖�j=��=-D���<�Z=ɓ���;>���^���U>�Er3=h������ۑ�6�Q�j/>I�d>�֓�{�䁂������}='>��<>~�=}>���M>��Ծ�_ڽ=��N��=��=Ԁ�>s���5<$��<O����>A��=Dm���z<��ݾ�>�>��޺i=AX�=Z�>A�Y�:"+=���w->��=�vʼ�w���]>}��]��=���>I��= L=��<�=9s����S�Ʊf�7~Ľ��M=����ض3=����V��H�(>�UA�c���Ĝ2�z���S�=���=�Z�=TQ>�1]�+Y=|����gU��\J=���=w?��5�=�N�>�n&>X�q�$2q����=�M�=s�ʼ�1=�ꦼQ��=O�0������������q[���iF�k�s���t�q@T��&>a����<��J>�.ս�3���=�s���%�>��>���b�2=?���2I>�4��=7��=tl>٘>�TѾϏ��H2�1�J�Jk>���=�H�=��>�<�GS����=��r<��%��ڊ=�rk�.1=�q#�H䧾zB��� ���P�rͽI��=��:U�2��P��^��<j퓾�ޔ<q��=IJ��<�r��&8>R*�@z�cD�,o�=Kgj�N�m=Z��Z_��ѧO>>
8��3�N�\�2?���{:�K�C��`��Y�=���>QW)>��'��)���P�U\�;Kd�=���=���=��ټP�R��	=�q�=�f���>L�=��>�7>�uQ<�T����Vֽ"��<�g�=�܅=&"�:V���9=�Ҡ�ڡ�ZT<����=jO��>Q��=��*�	�d�q5�=��V���O�Tk��l�I>�܉�Led=��?�F2=L;���k�=.�u�w(>�'��	}>�8>?�?��1ϽCF$���$��O��d� ���S{��+=Ƚ�3�
������=�G�=��<�=	�=D����I� @���b��NU>.��=��Ǟ��a��=��)>�����<���Xc%�����W�=�[[<Y�>�9=$ҍ<p������J��ӓ��g�<ӡ%�\�#���E��M��J,�=�$F=�؂�|h�=5V�HYb��h�r0��S�򐽳~,>��7�1M��pK콒y�=�d#=�hJ��>�T�P}L��pQ=���=�W_=�,I>M(S>HM,�kS�C\=�Z��(b]��>�>�$ �2ȉ��e�=��P�o}= �+�a�ke=��>r==Ż���_۽��,�
:0>$��������k4�y�=�<Z=`%G=�J�=.\�>w��=���T���������5={��R5ľ�����/�HA=�z	>������/ܽWM�$}3���Gt%>]��=���=��w�����Q�e>S��07�(��-�>Հ�BP%>�\K=���F�8�u<���;� >C8��R�|��<��}��~�>u��=��#=�0²=z	��X=B<�=� ��v>���>L�>�ׂ2�T�������m�_�8�UL���2=�x� �	����=�
�"�R>w�w>�嶽EO�=0�[=�Xo��>!iG����=�3׼����F�?��={��� �7�uf�=D�>#F=��<���>#�x��⛽V,Y>eJ>>�8>3�4�
�>'��t��<��<��*�h|�=�vK�U:���I�=>4$�W��=�����\�{�v>���=t����u����>�W��޽e(�%���#���GQ���"��W��b��=6���G���j�;�����=��Խ��F�T�ɽ)T=�ց��$���X|�Y�󽾕��Ј6=�/d��t�T��<���?����+�����>8�=D>�=�˝�4���Zͽ9�D>�]i;5�u��b}�I�5>��=�p���ZG��C�=�W>�����9���=_��>=����*�&�ks=E��� ��<v�=׸��C3N=ө������2��^7�\*�uY>���ܒ�=f{���=,޽�z�<��<�;i��;��L�꽗�E�5��= /*>��9>�ױ��:��SS��<����`�
>�]���O���=�<��Deڽ��0��D�<=L>1(�=��m��D���U��:8����=Ϲ>z���{=>N1>[����A��Sh�=3v>V
A��cN�!�=LdV>�žaG�$9�=T`Խ===���4��g�=�B�;��U���,�S�N><>:~��9=q�>>��c��'=�:��>bd �?�4���D��,>Z&�6�
���=?lf=A�=��'��x$>��6>�b��}�=31�=(˔>�#=�Β>J%>N����u�%������=~���B��<1P��`�>�
����<=b=O5����fwg��V��.�<IQ��ӽ�8[=�k���邾9i`�C*���4>�>���F������B���ch��z`<ޛn��(�=����������=aS;�8;0O!��S���=T��<�e>�(��J�<D�Y=����8�ϻ']�=`����f�=,g�$��k$v=�g6=�6#>��=W?�h��ڍ��d4>���=kp����پ�ƃ=��K�P����u>�/
=�c=.K`��)н2��<�y������=��ӌ��W���-(����w�*��=�禾2
>��ü��ܽD/��=~=x1�(�u��S�"�W�,= L�5^�A�:$L�=��#�����澱�<>}���T�=��I�Ƶk=�{'�����zf>��S�����n��K;_=�ȝ<t��=P[*=v
y�x�?�5�$=�񕾿n�=C<Z�����;�=�ɢ���_=9dJ;i��; �ҽ�+���:��y>���=c*=��=:M=O�D�&8�����=�a1>{�����>h�̾F�o��ҹ=׸��	��r��_���p߽|V�=�����`����ҽ�g�=cH�=����{�(7��ԁ����=����P��=�(�<��.�ռ�I0>=���АҾ�;cR�cy=<v�<E��=����v>�c9��=zU�&C�=X9�<�)��w> ����UN�+4����~��;��J=�5>W&�=�Ҧ=����D�ߤ>��=�e�>d��!T5��%�=�.�<�:U	N��Ǹ�(�,d��,Ž�)= pS=rѓ>���=����~0�0^>��x=��=le_�fИ���<��B;"�
�"q�=`!�;��.>�TS=���5f�O�=.@=��½��L�e�x=��7<�w>e��up�0t�F�ܽ*y�*t�=��N�q�=�*���cڽ�ܒ�)��=̆�=� �>�=%D��3a���W>���CjR��p->�=������=ɠ������,��d�������O!�i��=i�ܼR�;��>1q<<i�����0,�!�=/_��J��݂������滣H��:lB��ϗ:�%�=�Q=����[kh=Mk�[�}>I�#>�໽:��%�<qoѽR������>E6,�0]�=�����z7��O�<6}�=Y�=�]�½:2�止>���<�;�=�.;��_dm=?�=p'��=l˓��w>yȽ�5����=ӱ]>jĠ=��X���_B�= `���}����,��*~>���>qO;���>������a�;�=����>�cL>ݩѽ�����[��u-�������=���=;돽��'<ʩ��f)>H�	>	�=t*O=�@=6�h��+=�v��f���*>v�8�<�ʾ,>�a�=	�+�+N彥K#���=������� 8�>���S��==�7=��t��>�r7��҉�M�Ҿ�Y=E�=�\��]55<�r"=��4>W7=t{��SNT��e�=��>�qi�<Y��,X���=iG���	���Ļ>�E;Z��>T� >J�?����=~����[<iʽN�x��5H>�/!�&]w��8�=���|��=�4�N�=?d��ـ��k��ުB���D�ˁ��d<�n�K<V�^���!�9�׻�����>��_(>6�C��S�<�H_�$"�L�!�z�>>�}7=��k�Y>�=�x�M������Aw=&���#��=k�<��־�a2��=��k�A��?�=B�+>>С>���=d�<�n�<-�>��>��R<F!>��>��5�1q�*�6�<�>>�&����>�)]�y'ɽ�><�
�I���U>F��������8�V�N�0�s��H
��>ơ����i�`#��>/�==��Z�����ؿ�8Qk<��<��s><s�=[��=O=�l�렇=��J=��"��¡��r[=2�.���=�b�=6e��k&�9A���q�njm�R����ν�ƽ�u��&Ľ�+��\���9��>k�?�Z ü:Iv���1=2��=86������0>I\�I[=��=}(s>O�O��k��������>�����3���>3�=%�4>WZ>=+��c�8�a=,W�=ݒ!��9�ݮ��<�>�	ɽ�9F����<>��=8�~��!>�3�߽>�h9��8��uv�=�+&>8�>9V������!��F�̼Z�l�hX�����<�A>� ���-�ܯ���`=�=�M;�Y�S=��=���/>��C�ɼ˽]f����1�P�>� <J�V�=�߇�Ux�=QR�_˽=�6��|AM��F��*!>�b >��z>e�?=J` >Ju��[���y��ʶ��N�d=vヾZ�>��Ʌh��Mf;f�����:=ԓ=���=X̀��Z��ZT����=����"�������2m�����P��<?�<w͐��p�����aP<�ɯ=�bx�$H���$�<�%:����IAQ�}:�z�����z�яD=�V�<�����G�:�;��]����	�l=�H�F�c>�t��kt� ]N<TC�=�.���G�K3����ݽV�=K֌�]���H�<�6>��{���aP�<�K����=�"[�  c>���=#�">�۽ZT����L�߱�>'��-�=��=mq��Ȳ��u���潰(�����)8�~`�=��#=�.��������V��5#=�F��X"���}��	\�n<ν���U��[<��d�=`� ��	����8���W>a�P>
M3=d�T>Y�^�u�{���[���ʽ�_���鴾b��$�t=�۱=`�>ѷ)�;�<2��=�|H��2>YN��~=��V�~���@?�=3�N=����Nؾ�<��Ey�;'�\=����|@��+�>���=OE�<-� ���䎹�V��>"!��Z��3�P��F=�w���0���o>�HŽ�T�=iL= E��F�"��{M>��5����>������G�/���I7�����+�4��U�=��>v_?=�U��^<����<��]R �6�=����<�3=�$>�9?��5|��>�1�=Н��	ھ�.�<��4>�8ҽp�=�tG<f�=[S?���>��KѽG=��C>�r�=���m��=ÿ�K_������B=Q��=�ݭ�B��A��.$�����D��;��">�ѻ�#�PnD>|-���H;�3z>��J�m�h��=0�������w�=�(I�Ϳ�=�N>�J����½#>��M>�]ڽ���=��G�[ ��Q��%�ʽl���t�j�9趽$��b�=c�=O�ռ`>�Y�=��h�}$i=_�h�x��¸=`��;�����˽����sŁ���9����2䍾�YO>ڂ����<�gq�Aѹ��z6>a�ɾ�-o=�,�:*>\>�7�;�2���+���=��W��м4*>�C�=       ]H �=�>�s<>p�>�$[=i�>>ߪ�C��<=!�;�'�\	;�9�>��k=\���6���e�%�=�>��=���=�_l>       J�
��n�2�;<��=B�=l��"�7�|�g���E=`ɸ��нڇ�<�5��СN<V�ҽ�H��
���� >��>       ��%>���=Sj=*1�=��=��=�=�d�lY=ʌ0=QE>v5��KE>�F>��,>��r=��~=���=JZ�=���=       #J�=��=��x��d��:���p�G��Dc>m]�=��B=R�*=�.&=�c�ωa�DO�<!kd>F�;���]䃾���=��S�<���?M==tF=��q��P�=�W=j�̽���<��>���=nШ���"=cP�=�>zG�K�!>���=E]=+�!�i�so��ȸ=9�=��+�,Zq��ӼW�4�%��=�@�=���>�/_�����=�gX> �F�i3׻p$>�p:>gc�;uC.='ں�%\�'p�=n��=xEx=y�n>�܁=�%H�NI�='w=����� ���>��=">�=5�+>����j>�h>=0�=R�Ǿ=�ܽ�e�k�vaC�[0>�>�M&�Q����t�Jk8>���=�������=��<fs�=<i���>i�½�f>��'=#ݦ<lN����;�(��0[N�å�=Z�>9?>O�� ݁�-���9=�9�<�j�<Ʌ?�A�ٽ�'F��~�=�3>q?��+Ǳ<&�<<=�<&7���}:�����a��������'>w��=�u���<�o;�(i=�xĻ�g�(X�=�&ͽ��Ktc=V^|�c��=����H���Ͻ�%=�u<���=j�Z=aS�=ҥ
��>I�>��ѽ9�<:a�<w
>��)��\=���=��Q��f�߉�ʿ>�Y$=��<yc@>�o=��h��$Y=șA>n�=X@#>��4ޟ=��I��l��h�����>'�==���+�ҽ���=�5l=`�l<� =`�d>h`�>�M&>�jw<[�9>C ���=@m�~>��=��=�h>f�=c>�筽��M;�>>(:�;���=��*<]G�=�w9>�*�����=�h>˧;=�4<c�=�'d�h�Q�ֻP<Ż>��=�g���U.>�Nx=x��= ���R>��i>��>�(ɼ���>G��=�F�>���󴤽˂��畟������=8�=�_���=��T�i3
�|Uf��G�>hl��=>eM:
�t����@�=�!	���3>�E��z��@7�4w=�>�<PE�;����א=WE!=�^�=*c�< +���=?��=�2�0ޔ=K���Od �1m�=���*	>φ>{��Rz\>؅�=�>�����mƽ����n��:
�;4��=iۄ��J>�ýqzb��'��K�=B��m�	>��#��|=��=�[���*=�5���=�ν!lN=�ľ=D�*>���; ��nu>��w=u���1��w�=�)	�ht+>w���ޙ�s�"��3>+">��>ij��F>2'��~u=��+�-�H>�g^�Ib�=�$����=��^�l�>�.=���=�,��\@ѽ ��v��>�U����4�owq���=*�����+5 >I�:S�R=\�(>���6�$=ZE��K=�ȇ�{��T�<�R">�J�����GϾ�X>�y �e!�=)>�y�˽[>I�U��l:�1��=���C�;�����3�O{i;�d>����>�x��a%��u=��D�=�X�<�L񽋮�=�;=�=�Ά��#o���z�_Ļ��e�Tx>��/>�)�=�d�=�T�H�w�6>�����>0G+������<h>UCh=�z��,N=4֖>� �'O2�+�>�=��;>9f�>s�Žl���`H����cO>�_��M�<�m��>:�T��==͋���f��'=�B
>����M����O��Q>3��=s�=���=F�=�Uy�t�־�!>�D>��<9�s�ɝ=���8>ۥ�<���=_'F��=����>L8�Vij>�'����=�A�=��N>�Ӣ=}�,/�ѯ�=7Y=�+�=�����>:㵽�]>��>�+>�<���=��,>"�<��w[<jr��m�0�e�.����=��p=Q��ȴ�>�.a=|�Ƽ슪=�:9�N�����>��B>yb;�f�����=��1��`>"?��Y	>�#�?ٍ=��^���&>?�>�D`>�oս�U��!�<6�=�J>��^>�[�_	J=,�=[;��-?=�����H�t+,=i~�`��=�$ҽ[肾��>9>B(+>8`U>0��&��=B=^��<��=c,>�:>��q�����"�k���;���>��=)�V=ў>�
;=fe����+���Խ�U2>��]�G�
>��*=����q����)<��f>{ݽ�Z�=�NK=~=�7=��=Z>�0����p��g٩=�h��G����x����׀�<�>��j>8|�����O푾;I=��l�S����sf�>S:}�>���f�ĽP��<K�z=t��F��ǳ�>և@=R}�=�J��m>BĽ�^�<����Mw>����i4>á��>_e8��Ev��H����=��D���<fBL=;�����A��ݢ$=�D=�uK=`C�=\�R��tI>!�xp<�M�c�1=x�>�D_�N�4<]�P��l����=���=j�K>�u�=������=a�=�S�=W�==	(s��m�n{�g^�� �>�����]��vn���� =���;��0>_`��s��=C,�(VQ>|�o��>��/�OJ��]p�2�S=� �ճ�=W ;>޼˼5� ��N�>�K�>��3�>�M��<<y=���=O;�n�=�`��2�=v�^���>$�=a6����<�혽v��<-p�="�d$>�\�:<܀=��d=��/���齌[=3~�=<kս�`.=�<&>������޼�F$=�RK���;L?>�l=��z>�4=m�;�ս��">��P�����m�=��>�D>�Xu�h��<G�<3e=��'>��>��R��>e>�r�=�̱=�IսA�F��~p>�Xʽ&"/��l�y��>��H=B��=��=�a�=p���{�=�={��=`�=��=*w�5��;y>yݫ��xN='4O=�ν���&½l�=���ߜ����4<�l��>j<Ve:$����=�R��k:�ӗS>�!A�Cir�3�ɽ%4���E�����{�4>/:h=mc>j<���d�9>�d�=H�T�2>,r��j�>[�ڼ��;O�+>V�">Oa>#>�C�<d��=A����=�>	�Z�T�@=�N�<0�>������='���w 1>���sC=�٧�R>��[=�>��
>º�<d�=�~=��X=zBi��4?��<�=2�ͽ�14>E�*lٽ4�Z�PA>�B��Ok�L�𽭣��>��P.�(���式�����w��>�~.��G���=�ʏ<�?�БT�k��Ї���f�V\����=���>RY���ؿ�g-�=3�i=���ovh�'�������>y�V`o�I~>�/v��u>��	���=A�>$?t� �9��*O>��T>�b��=S�=�>�O`=ЪO:ps>h��=���O']=U8�>�鿼��=�T:=�@@>��0�E�N��Z=��=�?��L>:�1=fb>��>���=���=�T�eF�>ss����b>G���<�~��=���=np��J��@!����`��eý�XP�ka=�F�=��ۻ�,��A������>^I��=4�KQK�
��>�g��g_<H`&��PM>���<T��=~I���`���oN�O#�<�/C=���>�=H���8>Vi%�?�V�n�+{��-e"��ٮ����=�U*�ʖ�=~���Y�N�����7�>'��:�������=����=�&=��҇��T����a<x���udo�ϧ��y���^�<u�4������=P���)���<�<q���ܽ�@�Qߘ>Q�e.W<���=�I��BF��g5=��kT��/>�u�=��c=�[=>dQ�?�2�4�c=|I��75e<+Ʀ��I޽ix�=^�>Zz��5oJ=��>�,�����P2��Ӧ=4���yR>�G�<�;ֽ�4i����>���<��8>0/*��F�=�VP>w)�>��W>H��:igi>𐁽2i˽�ټ;���I�=slm���F��v�_�J<ʈ��N4y�ڟ��s���1������w>���n��Y�>�=>� �=���`�y=�8�:a7����=�V>�OK>�Z>�D�<�Mջ�"�/G���[W=t����
�����S�S��2�=.g=�J=���=��T=^Wf���Q��'>;S��=8L���Cɝ;
�<!�ν\>��=��>W�|���>d��<K��=�ls��;U=>��=�&%>���;f_>�"o�LF�=&wN�{Ls;8�9-5���m ��Ȇ=�}����>6��� =y�=�>�J=͒>�!Y<';Ľ8���m;�
ȽG��==��=[)z=��=���=��-�=^��=��>��>kc�=�cJ�E��t��Z�0;0�=]�=�u =���<Y�/=�W�=o�ʽH��=ǿ=�##�0���a�,>A.�(zy>��>^�z�rdU��I�>��*��2��d�=Qܾ���=��Y��=��*� Xo<s������=7G>�y`={��=�n>�R=�~���Y>��r�| >� �=7oL=�Y�:4�<�1�=�¼<C<�<0��<�<�<�����x�=7#���'=<J�T>Q�{;7o>�/>��=�*ƽ�it>TŨ��O�=�r�<�i%��;�J_�=�7��3>V��#����>����);<���ֽѫ�s �=�����>87�Ǻ>�5D>z�����U>�>����b�e�SP>��<5�>�@@�!�B><����}��~�G������� ��&��=��!���>SXh�:;�5��<�E齏o�=��3>��[0�<�S">��[��_�&{`>�rJ>x8>��s>/=l��Z<N�=;�V>��"��=��>�[B>��\<��>[�]�g���9@?>Q�߼�g>��O=�����F��!=���=_�����zj->^dn>�>�@�=M��<{�r�*�K=d	�=Ur�;d0`�n9�>�t�<�ֹ���+>8"#�:9>��I>\�Ƚ���=�=?>E����7����<����;���r"�<���=�Uv=�c�=��$�]l�_Y�<K���Ӡ�=DQ�=r�6>Y�a>�o>��(=Ӝ��r���I>_i�=�wq�E�:<,Z<=x�7=.<�=T�U=n�<7+ϽũU�H}�lþha=Ј�=^ި����>��i�r=����؛ >��ƽo{@;���=�I*��3J>��,=�V��')�=���=h'�<�ϳ�4�v>�L���=0=�w)�O<p%5��={�=J�N�"�B>U_�S����r�<�o/���)���=�=�R��kS��>>���Mr��t�=���<��>�5��b(>=)����н��>�����>[DB=���<�l�W�k��A����5?��{>M9��D�	�8��l=��>8kw�$��=O����i>�[3�ޔ�d:>vl�%���K��`k
�%q�����=�FR��	/��H���K>>o�ɔ>�� �;�������<�$�<|��<X��<��=�kL=:{����>~�)>��"�Rx�=k�-���>},�<�޸�8�>��>A��=G5;�㛼�=_Ã�����O�o,�>=�S=7�=#��<�x����� ��� '� )�;U�;	��4}<י�;�^�������E��Az��������v���q��Q=f��=ݘ=a��?o��w�=C�=y��G"���K��c��<QG>�ٻ=b�<~!=Z�> >��>y�t=@X��n�%�w��=^�νV}�<a�K>G��<<�=�8���K>-1�=��7=s�ռ��6>�륽�k�<rXx�XM�>Z	@>����r;�3��%����m=v��=tL>JA>LM��c��´��+
�7�@<�Խ&�>���>�r�=�MA>;M<�=X}>�I]�Av�:�9�8��<�:>z�=��=4	U==�"���}>��>W&=kw�=����w]=��L���Ё��u9'�]��=ҍ�� C�:�Bx����S^��d輼�D>\ĉ=�K;���=���ʾ�(�}=|Q���=Zɼ�>n��=؜V>O�G�'9��@=(���H����ý���=��>$�7��=��F=��=��֬=ϙ��y��>��Ľ�'�Y,>�Pǽ�뤾&����=)�����Ǧe=%+[��h>���>Q�.�k@s>����a=y�>� �=��>�c����2>�=�?>�r
����=z�=y� �o+�=�=��(��Ta<p����0��s>��b<�u����n��C���3;�=/���&>?Ŏ=h*���V=��a=��e;)e�lD�=�/�=�ۼv}�u<N>T���ϼ��?Z�=nA���=�X����.<	��<�=ޥ6��A}�����DK=Ê��^�<Ҁ�<H��=K{��j��s�����<��lw�<�0�[j�/l!���F�f��7
>�z��u˽鈮�#�=<��=�<"˔=�P*�9�K��$>x�?
�9��I�=�D���3 >��;߭^���1>H�=$�R>�ٽ�'>�=��%=!H>������>!��:�2�>�$T<,����=.܊��o<����=]�=��A�G�j���@>���=b>/,�H\>(\�=�Ƕ���c���>7��=�g<7+(>¯�=Z�����7�����8�=�9>m1��n�!���>��)<��<>�=s:��y�<�	O=|�[�Z���W����=P�>	�-�H=J ���>����������Y>��˾,>��@�#;��=A�߱�<d��=���@O9<"f2=��>���>a!�>�iJ����=S/��V����Ƽ�b<l	��V��"�o�	��=jH5=4o<(�="4l<�Sٽ�Iu��X2�ʇ�=X@F>�8�>�ݽT޼�=�? >$06��R�=L���->���>M����=�s��j����g>\ �=Ss%=�v�՚�=(��,;䳬��[���=ǌ�>�>��#�w��<�v=B)�=d��;���Pw"�ta�=�pa>8�Ӽ�V�>Ǎh=��=Bf���P>��">�i=��L�.�>�s?�َX����:��������<o�<(�T>"Ĭ<��Z=f,��Y�=r"��BK>54F���>N� �"����ⶽ7����$���B�Y������D=�b>��O��N���5���M�?��=~�̽�(�={Q�=��Z=��t>욦�V��v���O>��ӽB8X����=����\3��Ӛw�h_=���>��*�P2R�S�ƽȸ�`���r��>�s��v�C=�&>����:�=pE0=b�V=��_<?3��P��<Btp>�x����	�y�.>�J�����D�f�1|>�j�=���OK	�'�ٽ���������ؽWyc=Ǜ���W=֧T��~�>�2=�A1>�L+>�Ե�R���%<>��̽(&�<�1|>�1��n]��3�9�ън-�>w[*;I�>�K���d��C�!����=9�2���;9����=��4=���=�+*>��<^��.{ٽCz�=�=�=$�<�p'�=���Aν���>A� �WL��b�=o�{�M/�<Z��=՟�=���>4a>�b��l�q�;�)>q�=a>^tμ������8�%��'0>LO�=��<ga$��a>aV���;WHH>�]�)f=��=����\>���=�pz�9'�P�<�D<Jh���>~�q=8t��aB>>��>Oj>��f>ր�=ĵ.�t�Ż$6Q=F��ߥY�#�>���=#�>\�&>b��8˽<"�½� R>���>*wy>��,>��Z>�I>}&ҼX{�=Uk�S!����49���g"�=@2�a<���<�s�9���=R�<�m�=�ܼ�>Chn��|v=�+Լ��=�0�=TI��:�=H�T�h,�=�B�;Fڼ=��J</��=�5H�r��=���=��=���d�6>�hd�^`�=^Q>��=4�����u��=�����<�5�=���&)�=�5�=�f�-�B�^��=�>� >� �=�N�=��>Wɗ=�1:>�,�<�&=0`?�W8߼���=Kl����=f:>��<��=z�,=�8
=�/;�a�=<�'>#��9L>)�󼈍�������R�訽��Z�����Z�vC���@�E��=�����g�<Z罫H��{B�=܍�=0�W><Q!>P��Ư��/�n�>��)��% >E�>��;����=Zj�=�/�T:�=�g =�*<�瞽�<�=ƹ�=m'�Pl">/���n?����
�a;�<)I�����V>39���H=�+>��ݼ���,��=����=���]�D�F[���Nn��̾㙆=����a�>7/���C>A��5����D:n��<L��p!�g �>:�Ѿ�݄����<�b�>QrƼ��<�g�=C�=k5 ��a?��T>�@`< %'>y/��#V=Z�#>�	�����uƽ15�Nk�����14=���>�n�=	j���B\���˽XQּ��ݻ�½���;�9>����^	�{�,����l >N� �@�=l�����d=ӯB=�F��	}Y�tνq5#>i����>��齵�K>N�7>n�<#���Me�<���*ʈ�Ke�*ԽQB(��"#>�����U���m���=�߶=Й���QN�6ʧ=�/s�5z���|3=�>�B?���=�3� =�r۵��������=�q=/�y����=T�ý���0��<;o�pb~��T=�� \�=�-۽��=>��<���=]����%>���B�p�xir=�T!���#��}v=��� =��������ƽD�:�)+�������c�=4��=�K�)X!<�&2�ge�=vQJ�ٸ�<$�=��|��N߽�պ=r[�=*D��1��X߽����^��1���/���%>�}�Q�W�4i >�J>T<9�v�S<Icr>>�=&�_�y��<A�-94=M=W�վH9¼e�w=��>bWb�4zf=�瀽 �����{H<>8�
>&��&��<3;>��K>i��MV��{2>��">������]=�&��Y��=���~����p�U���k��Ξ=V}½>=�+==ĝ���<y���Q�<,�'�NJ�=I�M>B���A;���W2>sc|>�s?��2S����@�n���彣��=a)!<��=|�
>�����MT>@ݽmX���u�R���?�ܽ�4~�=$��*�4�7Z�<W�>�@;��]����<�c�8>����9//>�|��� </<:>�	���wݽ;��r�>���=�</�MO��w��o�<hԀ�}ڦ�g���e�/=,}����>�}M���=�sE>r�����v=�Y�g�%=�>��>7W�*�x��K׽�?U>{D����`���=��:��f=x+>�z�"
�=s�2�XW�;{�=[�W���S�8î�0��<M��%:༙Q��$�����z<��>��>�[>�)�����>��=�`=2�g=�|��� >�5�>{�=���,�=M��������19�gxؾ4�[�.>U��v�>�
�v��=��j=6{���=�r7=JOX=ۮ=�s�R.>��Y��<��=��=ޯ�!��t��=�(g>"�����4>]��>�=�ǳ�9qF>C�<>wS��+�=v/�A��;C�\=����.�=�'D>��>^UM��ѽ�o
=�1�<�7��%�<8I`>��t>"�8>� �q�=(np;N�S�Ni��,_=P�=�U>b�=�H�<㌽�<�>i�=0� >��	����=����Wlw����c9�=����{�m�]���7=�C<ӻ��n���������U�<c��ݎ����6=�e>���/�=&:>_��+�> *�>e�<���j>�4�=G�=�0��>48=pJ>���(�T>��U�_B�>ڐ���M��ʝ�}V˽lu(��CZ�S�)��	q>��2�miw>��.��C�^Z[���>_ν*m">s�[����=n�Ƚ2�#���^����X���B*>�=��>����a<&�;\>n	N�7��=e�.=��9�ZP��OR>Dq����=Uh|=@�=b����DN>K�0>$@Ž�5�=����n	ʽ	\�=���=8�=�9'=i�=�1>��i����<��;�B>�Զ����<���>.�.�	�O=7��>��I����=S&�=g(l=�z>��e>k:<j�=��ʽ"�<���=W�ڼ;�=�Ա=_�w=�R���<<S=�VG<E�h>s쒽Į�:G� >��3�DU��+��<���=������;�J>�[K=ؒ��%��&V�N�ֽ�R=���jV<�Ҿ��7>O2��v�g�'o�=u>�2>D�o��ob��oA=D��:��f=!X���S>�����= �	��1F�C�>�0��O�<?�>N&��� =�������D�<u?=ck���>�~>t	c��>=�2��E����=�˳�o�F�'��=��<�p�=*G�>ؘ�=s�<��!>�ま�z޾��=4[="�p<Pr�=f_���<V⌽Su!>���	��>�ާ��*�=T6��L弪���ܜ��x=V�F������=�Ɠ=�mѽ'��;k��=�2l�R�X>璎>��,��V�=�4X�}�=���f=��ݽ;S��Z�>`%ĽUl>��=h�h<'�<ǒ=�2.�@$�����=zBw=��>[u >Јo�cC�k���ޓ�<�v=ӫ�>D���6>|-<�^f=X�3=j	���3 >XZ>�z	��P�=��o����y��<�&��<7q�=�꡽3�X=|~G>l}=����e�(=�~�;�f�=�C=P@ >.>nD��̫¾qVk���=O���[U���[$>�>��6��(�={�?͈	���4��}L>�F�>�=�fi���D>Ó^=E>��2�����}=�ˁ�z,���g�=%Y�<�m->�;��s��L��?	[��4=m=��<�-�>��～7�=PB=f��������)��U=A�=���=��k>�Y��Ĉݽk�=nx�� ��<*B��.>g�)�/iV=�~�f=T!���=�<��|>ǲ9��'ӽ�?�x�1�n͕�F����۽�=�		=o%=�=��D>�E=�8=B��-Ad��V*>&>��m}*=+�p=x���}]��$>���Q��q�p>)��>߷>HZ�=�Ö=����A4>�Y�=-<�6>J=��ƍ��
�h�C>���������P=
��=��=#�@<[NǼ�:\<�F��˼�̚=�k>�qƽN����پ���=�>g�W>��	���=ڐh�I|7<F*����<��潚�h=�6=q�<·��q=o
k�EEo>��\>j�����>�� �߽�RR>zB�=\����'�=B���_���?|>f��^��d{k=DT>j�k>@Ւ���>b{\=�����ٛ<صǽz�_���A>���>��=�H���=�g�>W �О]=�>	��<dr&��K��dC��k��>~s=�&��L&>V/�<��>mS���!>�{�=Բ �w?k<�s�=0/o��Y�<a+��s!v<��������!���3��=<�rr=k���u>��.�s�=tX=O�U=�����,�;���*�����<s���eU���OŽ��V���U>�Zn��B��=o>gFy;���n�O��?�>h�_=rxb��]$=?5���a�͛=�9���y>s�=�aJ��>>>�g�����=�����©=l5N��>V���Y?=5�]>��=K��=֥��z��=�B�L����=
0/>��ݽ��#>e�׺-�=�y�q�=z �=óW>X���'�o=����n>��낲="�=�����&����ֽQ'�=��˽6��=��>�b����=�
�=�W��\(d=����m�)>�S>�`�L&�>2=5�2>��ƼVP�'��s�����>��=U�>Cp>��彲0S���w��vx���#���n=���ZGʽ�
.�
T���N�=�u�=Q�>����d�=1�=�#=	B۽�>�<���;%>�=�p	� �=�5>�?�<P�?uN[�u���n�犼=d=C�=Mg�=��{> ������=V!�=��3>��D��j�=���=GI�>�8�=jE��_�=a��>���a�B>bmԽ�ŗ����)M)>X4Q>��Ǿ�����=>9>�tԼ�M-��-ͽ-x�=(�ؽP�<YJ�<��;�մ�<+����o=�`>�(��Q ���=�0�=r%<XǾ��ڽH�J>�r>`R������=x�-���^�X�>SJ>���=��%>l��,�=���R�> ��;h�5=� l>�I��x�:�4�>�ӽ��P���=t��=_�s;Q홾�%��
>K#þU��*��]D�<^��= \�<N��1W>��K>��*&=c?>	Ȍ=}�=�A,>[�g�|���5�`>f�>M���9H��A�^Z=�>�O���i��=+ ���u�>�Y�_<�ż�"��g��,�m=t4>J>1�j6��)�oD>�=�ʈ=B��A3���+<X�<^�;�۾Ľ��=�ݺ9��U���f��X_>��ĽnXZ=��>�No�*��>������==3��p�E���}�>$�ѽ|�h�&��=�ힽ
��=)ň> xC=��Ľ4��=%(F��F2>��T�4<K�3>H����`�="�e�:`H�d�z>�L�>mp]�h�����s؝:=�=������=]v�=[X�����<�\j<�8 ��W���	�
��=$}��Md�=W�Ϡ@�+9��O2�=s���]��=�h�=�-P�D�I=�A>E-���i˽a[콄��=T�<�S>x�>'��e�>���ӽ���=4�[�%Ű�mFg�w��tC=�`���Zj� =E�">7�@����)P��Jҩ=ﭽ�<d�(�Ž��<;�E��Q@�j��<h�Q�-1�;����=��;���p&>�n����K����M޽�;{=�1�)?|=�m!��=MB}<mNU��� �Qo輼������&�l4=d-=���=��=V->��=���=��.��=C���� ��E罒�=�u�[Z#>�\ɽZ��=�y��s�b�8���=?H>M"�=�)e=aO;������s>|b�	g,>w���j�>��V=��=�9>(��=��a��1���5*>��=�*�z��>�.��J�>i�7>�6=j�g>�$�^B�=����>"��	>Ϲp�g}�<H�%���>0W�=������>�5���}<`[6>J1>��>#@=ڂ���ͩ>6H�{��}��=�x6=,uB��o��g�=��q���Z�>I���3: ���	=�����U��ݱ�>�}�=��=Z�(=�	�>����s��C	m��.>��:�U%:r�=�/�=%G�㜰=��'�X�=�����a��i�H=�8�u_�c����/��7>P�ʽ��,>�>?�X��<�:=�{=V�T>��Ὡ�=�=�[��>��>|�Ƚ��M>F��3��>��9�@M^��X>'Ŷ�Kv�@�>�WA�%#�=�s=�$n<o֚�F3�=�;���<.�]>�:g>�}(���1���7>�EӼh���cHf<�)7>����3�X<y���Z >��`��MM����7l�F*=���=�=F=(0�6�s�=Sa���3��.���S�>\y�.`=Ϭ�=�m�=�&=��>��=!,~>�ȾT�=[�>�ڳ=�	�'0>;M��w�=h<5��<�=�>�Z�=)^�>e�;= �w��'M��Ź=�O�(��;p.(�Z��=�������=�<ýa�%���7u=�>��֘<�F��X��=67;�T=y����z>����}>n��g&�=�����D��%�_�h>�G=�6�=���>"	i�)�	:���<���8ˆ=Ԗ����=��=A��>��ž�q�<U����>A��8̑<'�V��A�>��о���=}~"�m��NyO>ՌA��������Z>&�_=��=zΈ�.D{=��ʼz6)> ��=�F�>}`𽰧`=���<�T9=M3��=>D�ʽ�>LB*�W�V>;�������r
<˞�a��=3���b:9�=NR�>��=B0�k�<o����:=���V�f=cc =��: Q>�U� �=�%�=S!�B)��u�=3>�2K;��=g�u�b��TW��`ڲ�@�O��>���y1>�z)����>8�j�b�ؽ�Σ=A�ٽp	A��̟=�;�:�<�c=N�=�َ<�Z<�Uv�v��2l��ؼ��z��=�3w=p�m�f?�=E�F=NrG=�7>�S�<���z���6�>�d\>��8=�~$=�)>�I>��"����=M�}=(�Y=y>c�=WOb��������=�\�=!�D=p[�=>.��R��_^>A.=���q���N�=3�x�h��3�=>U\���y=`I�����=���=�~9=؁x�g��=�<
���f����=��l�c=}YB�Y��=ÿ,>�.>�ON��e>_K�>dk>_�0>�4ڽ���:�.��k�Ҽ˿������P�=���`�|>2�۽��=�'�X
�l���G�=�-W=".�=s{�������={ �=���->1�Q>s%�=��3A�=ܚH>��>r��<�[T��;��KU�y ��S�.>���ke>�k��O�>������<{3�=7�.=�KC�:�=;�=�M�>�׽�?潲�=�}_>�Q�O>C��i�>R���y���В���D=ˀ��b�(��m`=Ɉ�=��!��g=�<H�C���"�y��9`;�m�<�T���� >��	>�Q��°>:�=S��=�
;#���e:=������>bO<K�#�Q��I}�=�$�=����A9y��?>�]��@f��'��𜽨��={"�<Ɏ>�ه� �q<s�b>���<��=CG���½\:5=�H��>� ��Ѱ��Ĳ�F}�=��|��,����gwT=�d�vC�����=� <�l{��s)>�}��덼Ltؽ\�G�$�]�S�I=zE<�=�)>������9;C�  >\猽l⪻���$��)�<�KнnO���W���at>w��=kj��-�>��n�(.:=k@����=3���ؽ�w|D=a�&='�{���7=�x�[���!��׊=��;>_<	�/�KU��������;!�c��>�=��k>.b��bN�U�Q���R�����Za��$ٙ=��;abE�*���t�=���<���=�v�5�9�.����3c=O6�>%H�=�xM���ν��>2#>/��=���<kb{=6<�u��|P
<��=Dⴽ\���]��;���~�=RPz���������v�;鱰=�u=X� w.��59�a��<���>b ���/�;���� ��q���%*����=��F��>����;�)�=7�du�=i��;�v$=�d'>�;��ǒ��q>��=�M����<������<�q�[y6�=�e>T�����>S����qX<��,��ir=�i4=��<ꑈ=mM�;��
�l_�<�$�=��Q��<Yo>�'�<b���2��d�>�>��=��C>���=h�=��ͽA�m>xˇ�'Y�=��W>`�#���ݾՙe=E�6�0<Ŭp>�M�=�p>{�ʽl��=��+� �>��#>_k�BI�:ƾ����^WH>�;H>���;'>~�<�ڰ�䐾�=�=f�=I�j>gR�=�Tk�(]F�Z�c��C�,˽���=��c�h�n��ա�TX�����<C>%�%����V�>�B>"�����[=!��>R��3�=�V=9��=KL���4�7Ʉ=QdI>��t�`H�P�->��`�_<~�s�Mp>���I�<��<� �����=J�<+�½���=�>�(Jݼ��K�����kT��$ֽ᝼_�=_q���������#x��tF�����Pqн����x3<xq	�^�=������{<��E�����<��+�l��< P���=��k�"�լ1=�dмzX���ɉ���6�b$�<X��<������<ȵ=jv�����%qy��.�e�b���PO,�}��m㞽�ۙ=�Px=�����T��v�R�=���n�YHI=qf��ʪ��^>�G��m�Q=�P�@0=�yo��`V���ֽ�^	�p\����0�'Y<"���������ֽ��<��=�Y�A����g=�;�<3`@����=�I����Z=t�#�g`>��H���z> ��<c���5!�	��<d��ͺ/��h�P�ڼP�m=oc9�ЄҾ�za=e-���>�
3ٽ�M=I|>>#��R_8>u�>���<��=�O�=�(�<�i>+8=�B>�4>�0m���<V�����=����{��;���(�=���=�r��D3y>��[=���:�	�)M��iZ>	S��S[`;!����C=Bb(���+=wV���~;+�L>
�a�>��=GaC=��R�!=�=E�)>�i>����)=�>�s��	Sӽ��L�v}�=���=\5�=�|=��>�H#>mN\��.��Co=+��='� >������>O�4��ń�޽ ���=��F�P7����4�Rj���z�Bs(=�^�=Kb>m�1�b�<g�}=�g�=>��=�P>U�%���(>�;����<�]�K_>E��>�����VV=�G��q>���8žv�V=y��z�$�;Aͼ��B>͈=��>���<����r���n{��x+�kb>Z[E�4��<Z����f��W>eNE��ٴ<�>�=r�	��2A>~�	�ȟ�=��P>DsZ=Խ�أ$<���=�6=����z�>}C>�6��=�/��1G=:�>#=Gr�=j���	�;XR�v�_==��id���<�>ٺ����Z���ʾ,�i>����g���3�H�i<u�m<�%V�H��$j�=�~����K��)�>tE�����8M�2(�O����e��Q��)�_>����h�h������V>��<=��`�6��j=���t�5�w�����8��&y<bˉ�����T<>�˓>�ӗ��@�>o5�=��<�=�^=�e��9�����=��B=�ބ��y<�g-<����?��}�����=�vݽ &��Ç�8of=-0���g��.��|���,(����^>� d�my�<�����F��0>��G>!u�<H�>=H��=]z<D��;m*O���=A<O=<� >���;m��<� �W��{_j���<�&������L"�knv��������!߹KE=�W�䲼8��%�<��)>�r'�>��=ՖR�q<��7����ȍ�]�N=5�սt�ӽu|=��i�E�ѽ'��=j^�s>@=uu���d�gA�����c��Sν<T�;�k;=�i;��c>�υ�d��=q}=~*���=�GE�$@<&h�=J�L;��n��1K<���fI>o��=�����ý���>���rj�=�O>85�=�F>_�.<�.>aփ��v>��<#�=-�׵������ٽ�V�=�p�>,I>i���;��]�m��=BMܽF�^>��P�ZU5><��=G��=?o=��<^p���=�����>���=:������q�ѽ;�>1Z�N�ݼo���c�=�8^��o>�r��� =�ޤ���=FX,�5�=K=o�)�Ȼ�1�� }�X[>� �M� s>P�$>Py,�� �>���\Ɏ>\�&=�Z�Nd�����x�o>�+�=�F�"0>�b���P�=�C�?
s=�!<�[��=o��I.���S>Q����>?�N>�.!�΄��xɑ����<��*>�6�>��H">6�<��C�����|��=:��=_/8��!�9Y|�̵���>�\�=�t���\�=>%�=l�O���d8�=�>��a>~>��^>R!>}U>� q�d�7>�;G�*==?>F�1���P>[Se>�> �>��ᰴ�?��;G)3=�j��į<��=Ǡ���}0=_��=aE����U��#�=ւ?�9��=&�p��w��]
�#5=I71>F>�e�=no�#v���.?�@�<�GZ=�E�=�#[��06>�ʽӛ��\��;WʽBYN>��������$=� >n�/��{��wV�>@��=HW�=
퐻P�=��Q�P�,j߾���<��%���=!�T>�?�"�=ǡ���	��6Ľq��绪<����}�S����=�4H<�I<���=~����9|�B�f��Y�<7�=�x/��]�=�u4����<�텼�݊��;B�����Ġ=(�A�n��>����B�K=n�<�q����e:+���0ξ43�t�/=�⮾gf�=M�'>6㾞:�A^�=6-J=�R�=�)�=	>�
�=鄒�09�=Pʻ=4����J�<���=��=��}�a*I������d'��fM=&����>�p���>&>3����=wY��Bj=��=�c)>>?�����#ۤ���=L�:>��7>���=N:<KIb>�z�=���=W�>�=��M�;
�G�U=�m(>6�<��=Q�>��m=H��=^r�k�'���=�����0�=�~r=��ԼG!2������=�I=]I�<K/�=�����V�;E�ٽMF���/�=�����y�#�� q�gW뻮}=����'f>9�%=��=�>�R�=���q�;��=z��F�=�K3���#�ۚݽ������(������"E��W>.2	==`m>k>q�.� ��Uϴ=�?������=_��>�E��8�=+m�<)�=����0�<λ�<�i��,�=�j;�xT=w�'=_0l�`+>�΅=S�/>x�<o��>x\>��=��*�Ma½��>�:�=�%��Ha�<��>9Ԓ�y K�B�>�O>�H#��>���>�|��}�c=Mb<m������<A�R�g���$���=�mɽ���=57˽�|�;���nXP��7�~(ѼH���G|�=��`=I�=�v��7{��>Q�L�p�Q>B,P=ld(=Y8н�ZM=���u
�;p���}p>Iȡ��y<�=W��=��=�?�=Z�>�S�=�8x��� >�0>��}��?N�]�"��`ڽLR8>���뼹��!>;�>�C<}�]>cg{�(��=,�1>"�>�j�=�_?�.)=�B������_�>��Ͻ����[����>!����k�=�d=�f�>�� ��H=�t=Cս�� =����l�<u��>��<	��=�׽�qA�k<�<��L�3�a<�ǽvS�0� >j�<���><ٗ�n:�Cz]���H>1%=��<od|>�Ǉ<f���z�=�[�=|g���>�����=�����l>��e��K���.�<A>���=E\k>��0>a*�s�~>�4>K_
>^/���T)>#����'>�)����`=� c�<���=&����c=4J>~IֽPc>����r���-=2��=p���T/�>�a���D>c�:>NY�'E�n��>�_?�C'>/7�:�Q>�Z*>���61��ʽ���<O��=큩=�D½�<X�=W{=N >��%��.>pn�8���J��a�>,c%��%>~O�=����r
=>]�<�^=�Ek>x�������q��=�F�<��<�㕼=;-��+0<y��lXq<�z�=~��=��:Nw�=I�=H��bH=�~��=�=���T>��>�8���z�6�(�,��;�:�=Dc�����y=�EϚ;����Z���	�e>����;f�=,�������9��=兜�������=�3�=�^;���%�L��=��=�t��*}��Q�:��왽�4%>Ng�=yΣ<�S���
�5H'>�]@��ɽ�?>|�=�ҽ�>�~����s>R�����]���R>���&�� 8>T����_T>'�''>�<��ؽ)V�=�=E���xq>u�}G��R>Z�$>TZ�<��=>�F�=Eݽ�~����<������<ݍ�=!:.���b=۟	>�Mm�q0<a"����p�Ǿ��V�"d�^".>�}�>g.��g�=��1��SH��݄�$����>�;��$���Y;�Ւ�\T���n)���:>쎾>\���Tl��X�3=�8>U��=$Y¼|ψ>f������<X�Ǽfӽ�!��W�>�4>꾸�bUQ>�Y��N��F��=v^>^ >�xO�"�g�]�9>������ >f��<����6�R>}'$��D���2��Bv�����9�=�S��T=���>�>�������0=��=��=��x=�c=8D�=-BH�!����S��4�+�o�� �n=�,����=�[��|�0=�1�4w��M9ؽ       ��?(E�?ˌ�?a��?cb�?@�?��?Bҭ?6�?��?,��?C�?�P�?*�?_8�?y@�?��?�U�?��?�T�?